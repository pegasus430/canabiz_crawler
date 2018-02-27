class LeaflyDispensaryWorker
  include Sidekiq::Worker

	def perform()
		logger.info "Leafly Dispensary background job is running"
		@state_abbreviation = ENV['LEAFLY_STATE']
		@city_range = ENV['LEAFLY_CITY_RANGE']
		scrapeLeafly()
	end    
	
	def scrapeLeafly()
		
		require "json"
		require 'open-uri'

		#GLOBAL VARIABLES
		@source = Source.where(name: 'Leafly').first #source we are scraping
		@state = State.where(abbreviation: @state_abbreviation).first #state we are scraping from the source

		#query the dispensarysources from this source and this state that have a dispensary lookup
		@dispensary_sources = DispensarySource.where(state_id: @state.id).where(source_id: @source.id).
								includes(:dispensary, :products, :products => :vendors)

		#the actual dispensaries that we will really display
		@real_dispensaries = Dispensary.where(state_id: @state.id)

		#query all products to see if products exist that aren't in the specified dispensary
		@flower_products = Category.where(name: 'Flower').first.products.featured.includes(:vendors)
		#@all_products = Product.featured

		#MAKE CALL AND CREATE JSON
		output = nil
		if @city_range.present?
            output = IO.popen(["python", "#{Rails.root}/app/scrapers/leafly_disp_scraper.py", @state_abbreviation, '--city='+ @city_range])
		else
            output = IO.popen(["python", "#{Rails.root}/app/scrapers/leafly_disp_scraper.py", @state_abbreviation])
		end

		contents = JSON.parse(output.read)

		#LOOP THROUGH CONTENTS RETURNED (DISPENSARIES)
		contents.each do |returned_dispensary_source|
			
			#check if the dispensary source already exists
			existing_dispensary_sources = @dispensary_sources.select { |dispensary_source| dispensary_source.name.casecmp(returned_dispensary_source['name']) == 0 }
			
			if existing_dispensary_sources.size > 0 #DISPENSARY SOURCE ALREADY EXISTS
				
				#if exists, then I have to compare fields to see if any need to be updated
				compareAndUpdateDispensarySourceValues(returned_dispensary_source, existing_dispensary_sources[0])
				
				#loop through products and see if we need to create any or update any
				if returned_dispensary_source['info'] != nil && returned_dispensary_source['info']['menu'] != nil
					analyzeReturnedDispensarySourceMenu(returned_dispensary_source['info']['menu'], existing_dispensary_sources[0], false)
				end
				
			else #THE DISPENSARYSOURCE DOES NOT EXIST
				
				#check if the dispensary itself is in the system
				existing_real_dispensaries = @real_dispensaries.select { |dispensary| dispensary.name.casecmp(returned_dispensary_source['name']) == 0 }
				
				if existing_real_dispensaries.size > 0 #dispensary is in the system
					
					#just have to create a dispensary source and products
					createDispensaryAndDispensarySourceAndProducts(existing_real_dispensaries[0].id, returned_dispensary_source)
					
				else #dispensary is not in system
					
					#create dispensary, dispensary source, dispensary products, maybe even products 
					createDispensaryAndDispensarySourceAndProducts(nil, returned_dispensary_source)
				end
				
			end #end of if statement seeing if dispensary source exists or not
				
		end #end of contents loop 

	end #end of main scraper method
	
	
	#BEGIN HELPER METHODS
	
	
	#method to loop through the dispensary products (items) and determine the correct course of action 
	def analyzeReturnedDispensarySourceMenu(returned_json_menu, existing_dispensary_source, is_new_dispensary)

		returned_json_menu.each do |returned_menu_section|

			#right now we are only doing flowers
			if ['Flowers', 'Indicas', 'Sativas', 'Hybrids'].include? returned_menu_section['name']

				#loop through the different menu sections (separated by title - category)
				returned_menu_section['items'].each do |returned_dispensary_source_product|

					#check if dispensary source already has this product
					existing_dispensary_source_products = []

					#if its not a new dispensary, we will check if the dispensary source already has the product
					if is_new_dispensary == false
						existing_dispensary_source_products = existing_dispensary_source.products.select { |product| 
																product.name.casecmp(returned_dispensary_source_product['name']) == 0 }

						#try alternate names or combine with vendors
						if existing_dispensary_source_products.size == 0
							existing_dispensary_source.products.each do |product|
								
								#check alternate names for a match
								if product.alternate_names.present? 
									product.alternate_names.split(',').each do |alt|
										if alt.name.casecmp(returned_dispensary_source_product['name']) == 0
											existing_dispensary_source_products.push(product)
											break
										end
									end
								end

								#check products with vendor name
								if product.vendors.any?
									product.vendors.each do |vendor|
										combined = "#{product.name} - #{vendor.name}"
										if combined.casecmp(returned_dispensary_source_product['name']) == 0
											existing_dispensary_source_products.push(product)
											break
										end
									end
								end

							end
						end #end alternate name test

					end

					if existing_dispensary_source_products.size > 0 #dispensary source has the product
						
						#if product already exists, check to see if any prices have changed
						compareAndUpdateDispensarySourceProduct(returned_dispensary_source_product, DispensarySourceProduct.
															where(product: existing_dispensary_source_products[0]).
															where(dispensary_source: existing_dispensary_source).first)
					
					else #dispensary source does not have the product / it is a new dispensary source

						#first check if product is in the system	
						existing_products = @all_products.select { |product| product.name.casecmp(returned_dispensary_source_product['name']) == 0 }
						
						if existing_products.size > 0 #product is in the system
							
							#just create a dispensary source product
							createProductAndDispensarySourceProduct(existing_products[0], existing_dispensary_source.id, returned_dispensary_source_product, category_id)
			
						else #product is not in system
							
							#dive deeper for a match
							@flower_products.each do |product|

								#check alternate names for a match
								if product.alternate_names.present? 
									product.alternate_names.split(',').each do |alt|
										if alt.name.casecmp(returned_dispensary_source_product['name']) == 0
											existing_products.push(product)
											break
										end
									end
								end

								if existing_products.size > 0 #product is in the system
									createProductAndDispensarySourceProduct(existing_products[0], existing_dispensary_source.id, returned_dispensary_source_product, category_id)

								else

									#check products with vendor name
									if product.vendors.any?
										product.vendors.each do |vendor|
											combined = "#{product.name} - #{vendor.name}"
											if combined.casecmp(returned_dispensary_source_product['name']) == 0
												existing_products.push(product)
												break
											end
										end
									end

									if existing_products.size > 0 #product is in the system
										createProductAndDispensarySourceProduct(existing_products[0], existing_dispensary_source.id, returned_dispensary_source_product, category_id)
									end
								end
							end #end of deep dive

						end		
						
						#either way I update the dispensarySource.last_menu_update
						existing_dispensary_source.update_attribute :last_menu_update, DateTime.now
						
					end

				end #end loop of each section's products
			end #end if statement to see if the section is flowers

		end #end loop of each menu 'section' -> sections are broken down by type 'indica, sativa, et

	end #analyzeReturnedDispensarySourceMenu 

	#method to create product (if necessary) and dispensary product
	def createProductAndDispensarySourceProduct(product, dispensary_source_id, returned_dispensary_source_product, category_id)

		#create dispensary source product
		if returned_dispensary_source_product['prices'] != nil
			DispensarySourceProduct.create(:product_id => product.id, 
				:dispensary_source_id => dispensary_source_id,
				:remote_image_url => returned_dispensary_source_product['image_url'],
				:price => returned_dispensary_source_product['prices']['One'], 
				:price_80mg => returned_dispensary_source_product['prices']['80mg'],
				:price_160mg => returned_dispensary_source_product['prices']['160mg'],
				:price_180mg => returned_dispensary_source_product['prices']['180mg'],
				:price_100mg => returned_dispensary_source_product['prices']['100mg'],
				:price_40mg => returned_dispensary_source_product['prices']['40mg'],
				:price_25mg => returned_dispensary_source_product['prices']['25mg'],
				:price_150mg => returned_dispensary_source_product['prices']['150mg'],
				:price_10mg => returned_dispensary_source_product['prices']['10mg'],
				:price_50mg => returned_dispensary_source_product['prices']['50mg'],
				:price_240mg => returned_dispensary_source_product['prices']['240mg'],
				:price_1mg => returned_dispensary_source_product['prices']['1mg'],
				:price_2_5mg => returned_dispensary_source_product['prices']['2.5mg'],
				:price_500mg => returned_dispensary_source_product['prices']['500mg'],
				:price_1000mg => returned_dispensary_source_product['prices']['1000MG'],

				:price_half_gram => returned_dispensary_source_product['prices']['HalfGram'],
				:price_gram => returned_dispensary_source_product['prices']['Gram'],
				:price_two_grams => returned_dispensary_source_product['prices']['TwoGrams'],
				:price_eighth => returned_dispensary_source_product['prices']['Eighth'],
				:price_quarter => returned_dispensary_source_product['prices']['Quarter'],
				:price_half_ounce => returned_dispensary_source_product['prices']['Half'],
				:price_ounce => returned_dispensary_source_product['prices']['Ounce']
			)
			
			if returned_dispensary_source_product['prices']['One'] != nil && returned_dispensary_source_product['prices']['One'] != 0.0
				product.update_attribute :product_type, 'Other'
			end 
		end

	end #end createProductAndDispensarySourceProduct method

	#method to compare returned dispensary product with one existing in system to see if prices need update
	def compareAndUpdateDispensarySourceProduct(returned_dispensary_source_product, existing_dispensary_source_product)
		
		#image
		if existing_dispensary_source_product.image != returned_dispensary_source_product['image_url']
			existing_dispensary_source_product.update_attribute :image, returned_dispensary_source_product['image_url']
		end
		
		if  returned_dispensary_source_product['prices'] != nil
			#see if we need to update the last_menu_update for the dispensary source
			updated_menu = false
			
			#unit = just 1 (standard for edibles and such I would think)
			if existing_dispensary_source_product.price != returned_dispensary_source_product['prices']['One'].to_s.tr('$', '').to_f
				existing_dispensary_source_product.update_attribute :price, returned_dispensary_source_product['prices']['One'].to_s.tr('$', '').to_f
				updated_menu = true
			end
	
			#price_half_gram
			if existing_dispensary_source_product.price_half_gram != returned_dispensary_source_product['prices']['HalfGram']
				existing_dispensary_source_product.update_attribute :price_half_gram, returned_dispensary_source_product['prices']['HalfGram']
				updated_menu = true
			end
			
			#gram
			if existing_dispensary_source_product.price_gram != returned_dispensary_source_product['prices']['Gram']
				existing_dispensary_source_product.update_attribute :price_gram, returned_dispensary_source_product['prices']['Gram']
				updated_menu = true
			end
			
			#price_two_grams
			if existing_dispensary_source_product.price_two_grams != returned_dispensary_source_product['prices']['TwoGrams']
				existing_dispensary_source_product.update_attribute :price_two_grams, returned_dispensary_source_product['prices']['TwoGrams']
				updated_menu = true
			end
			
			#price_eighth
			if existing_dispensary_source_product.price_eighth != returned_dispensary_source_product['prices']['Eighth']
				existing_dispensary_source_product.update_attribute :price_eighth, returned_dispensary_source_product['prices']['Eighth']
				updated_menu = true
			end
			
			#price_quarter
			if existing_dispensary_source_product.price_quarter != returned_dispensary_source_product['prices']['Quarter']
				existing_dispensary_source_product.update_attribute :price_quarter, returned_dispensary_source_product['prices']['Quarter']
				updated_menu = true
			end 
			
			#price_half_ounce
			if existing_dispensary_source_product.price_half_ounce != returned_dispensary_source_product['prices']['Half']
				existing_dispensary_source_product.update_attribute :price_half_ounce, returned_dispensary_source_product['prices']['Half']
				updated_menu = true
			end
			
			#price_ounce
			if existing_dispensary_source_product.price_ounce != returned_dispensary_source_product['prices']['Ounce']
				existing_dispensary_source_product.update_attribute :price_ounce, returned_dispensary_source_product['prices']['Ounce']
				updated_menu = true
			end


			#MG PRICES:
			if existing_dispensary_source_product.price_80mg != returned_dispensary_source_product['prices']['80mg']
				existing_dispensary_source_product.update_attribute :price_80mg, returned_dispensary_source_product['prices']['80mg']
				updated_menu = true
			end
			if existing_dispensary_source_product.price_160mg != returned_dispensary_source_product['prices']['160mg']
				existing_dispensary_source_product.update_attribute :price_160mg, returned_dispensary_source_product['prices']['160mg']
				updated_menu = true
			end
			if existing_dispensary_source_product.price_180mg != returned_dispensary_source_product['prices']['180mg']
				existing_dispensary_source_product.update_attribute :price_180mg, returned_dispensary_source_product['prices']['180mg']
				updated_menu = true
			end
			if existing_dispensary_source_product.price_100mg != returned_dispensary_source_product['prices']['100mg']
				existing_dispensary_source_product.update_attribute :price_100mg, returned_dispensary_source_product['prices']['100mg']
				updated_menu = true
			end
			if existing_dispensary_source_product.price_40mg != returned_dispensary_source_product['prices']['40mg']
				existing_dispensary_source_product.update_attribute :price_40mg, returned_dispensary_source_product['prices']['40mg']
				updated_menu = true
			end
			if existing_dispensary_source_product.price_25mg != returned_dispensary_source_product['prices']['25mg']
				existing_dispensary_source_product.update_attribute :price_25mg, returned_dispensary_source_product['prices']['25mg']
				updated_menu = true
			end
			if existing_dispensary_source_product.price_150mg != returned_dispensary_source_product['prices']['150mg']
				existing_dispensary_source_product.update_attribute :price_150mg, returned_dispensary_source_product['prices']['150mg']
				updated_menu = true
			end
			if existing_dispensary_source_product.price_10mg != returned_dispensary_source_product['prices']['10mg']
				existing_dispensary_source_product.update_attribute :price_10mg, returned_dispensary_source_product['prices']['10mg']
				updated_menu = true
			end
			if existing_dispensary_source_product.price_50mg != returned_dispensary_source_product['prices']['50mg']
				existing_dispensary_source_product.update_attribute :price_50mg, returned_dispensary_source_product['prices']['50mg']
				updated_menu = true
			end
			if existing_dispensary_source_product.price_240mg != returned_dispensary_source_product['prices']['240mg']
				existing_dispensary_source_product.update_attribute :price_240mg, returned_dispensary_source_product['prices']['240mg']
				updated_menu = true
			end
			if existing_dispensary_source_product.price_1mg != returned_dispensary_source_product['prices']['1mg']
				existing_dispensary_source_product.update_attribute :price_1mg, returned_dispensary_source_product['prices']['1mg']
				updated_menu = true
			end
			if existing_dispensary_source_product.price_2_5mg != returned_dispensary_source_product['prices']['2.5mg']
				existing_dispensary_source_product.update_attribute :price_2_5mg, returned_dispensary_source_product['prices']['2.5mg']
				updated_menu = true
			end
			if existing_dispensary_source_product.price_500mg != returned_dispensary_source_product['prices']['500mg']
				existing_dispensary_source_product.update_attribute :price_500mg, returned_dispensary_source_product['prices']['500mg']
				updated_menu = true
			end
			if existing_dispensary_source_product.price_1000mg != returned_dispensary_source_product['prices']['1000mg']
				existing_dispensary_source_product.update_attribute :price_1000mg, returned_dispensary_source_product['prices']['1000mg']
				updated_menu = true
			end
			
			#update the last_menu_update of the dispensary_source
			if updated_menu
				dispensary_source.update_attribute :last_menu_update, DateTime.now
			end
			
			
		end #end of check to see if returned_dispensary_product['prices'] != nil
	end

	#method to create a dispensary (maybe) and dispensarySource record and its products (definitely)
	def createDispensaryAndDispensarySourceAndProducts(dispensary_id, returned_dispensary_source)
	
		location = returned_dispensary_source['address'] + ', ' + returned_dispensary_source['city'] + ', ' + 
							returned_dispensary_source['state'] + ' ' + returned_dispensary_source['zip_code']
	
		if dispensary_id == nil
			#create dispensary
			dispensary = Dispensary.create(:name => returned_dispensary_source['name'], 
								:state_id => @state.id, :location => location, :city => returned_dispensary_source['city'],
								:remote_image_url => returned_dispensary_source['avatar_url'],
								:about => returned_dispensary_source['about-dispensary']
							)
			dispensary_id = dispensary.id
		end
	
		dispensary_source = DispensarySource.create(:dispensary_id => dispensary_id, :source_id => @source.id, :state_id => @state.id,
								:name => returned_dispensary_source["name"], :location => location, :city => returned_dispensary_source['city'],
								:street => returned_dispensary_source["address"], :zip_code => returned_dispensary_source["zip_code"],
								:source_rating => returned_dispensary_source['rating'], 
								:phone => returned_dispensary_source['phone_number'], :website => returned_dispensary_source['website'],
								:remote_image_url => returned_dispensary_source['avatar_url']
							)  

		#hours
		if returned_dispensary_source['hours_of_operation'] != nil && returned_dispensary_source['hours_of_operation']['Weekly'] != nil

			hours_returned = returned_dispensary_source['hours_of_operation']['Weekly']
			
			#monday
			if hours_returned['Monday'] != nil
				dispensary_source.update_attribute :monday_open_time, hours_returned['Monday']['Open']
				dispensary_source.update_attribute :monday_close_time, hours_returned['Monday']['Close']
			end

			#tuesday
			if hours_returned['Tuesday'] != nil
				dispensary_source.update_attribute :tuesday_open_time, hours_returned['Tuesday']['Open']
				dispensary_source.update_attribute :tuesday_close_time, hours_returned['Tuesday']['Close']
			end

			#wednesday
			if hours_returned['Wednesday'] != nil
				dispensary_source.update_attribute :wednesday_open_time, hours_returned['Wednesday']['Open']
				dispensary_source.update_attribute :wednesday_close_time, hours_returned['Wednesday']['Close']
			end

			#thursday
			if hours_returned['Thursday'] != nil
				dispensary_source.update_attribute :thursday_open_time, hours_returned['Thursday']['Open']
				dispensary_source.update_attribute :thursday_close_time, hours_returned['Thursday']['Close']
			end

			#friday
			if hours_returned['Friday'] != nil
				dispensary_source.update_attribute :friday_open_time, hours_returned['Friday']['Open']
				dispensary_source.update_attribute :friday_close_time, hours_returned['Friday']['Close']
			end

			#saturday
			if hours_returned['Saturday'] != nil
				dispensary_source.update_attribute :saturday_open_time, hours_returned['Saturday']['Open']
				dispensary_source.update_attribute :saturday_close_time, hours_returned['Saturday']['Close']
			end

			#sunday
			if hours_returned['Sunday'] != nil
				dispensary_source.update_attribute :sunday_open_time, hours_returned['Sunday']['Open']
				dispensary_source.update_attribute :sunday_close_time, hours_returned['Sunday']['Close']
			end

		end 
	
		#loop through products and see if we need to create any or update any
		if returned_dispensary_source['info'] != nil && returned_dispensary_source['info']['menu'] != nil
			analyzeReturnedDispensarySourceMenu(returned_dispensary_source['menu'], dispensary_source, true)
		end
	
	end #end createDispensaryAndDispensarySourceAndProducts method

	#method to compare new dispensary from scraper with dispensary in system to see if any fields need to be updated
	def compareAndUpdateDispensarySourceValues(returned_dispensary_source, existing_dispensary_source)
	
		#image
		if existing_dispensary_source.image != returned_dispensary_source['avatar_url']
			existing_dispensary_source.update_attribute :image, returned_dispensary_source['avatar_url']
		end
		
		#location
		location = returned_dispensary_source['address'] + ', ' + returned_dispensary_source['city'] + ', ' + 
						returned_dispensary_source['state'] + ' ' + returned_dispensary_source['zip_code']
						
		if existing_dispensary_source.location != location
			existing_dispensary_source.update_attribute :location, location
		end

		#street address
		if existing_dispensary_source.street != returned_dispensary_source['address']
			existing_dispensary_source.update_attribute :street, returned_dispensary_source['address']
		end
		
		#city
		if existing_dispensary_source.city != returned_dispensary_source['city']
			existing_dispensary_source.update_attribute :city, returned_dispensary_source['city']
		end

		#zip_code
		if existing_dispensary_source.zip_code != returned_dispensary_source['zip_code']
			existing_dispensary_source.update_attribute :zip_code, returned_dispensary_source['zip_code']
		end
		
		#source rating
		if existing_dispensary_source.source_rating != returned_dispensary_source['rating']
			existing_dispensary_source.update_attribute :source_rating, returned_dispensary_source['rating']
		end
		
		#source url
		if existing_dispensary_source.source_url != returned_dispensary_source['url']
			existing_dispensary_source.update_attribute :source_url, returned_dispensary_source['url']
		end
		
		#email
		if existing_dispensary_source.email != returned_dispensary_source['email']
			existing_dispensary_source.update_attribute :email, returned_dispensary_source['email']
		end
		
		#phone
		if existing_dispensary_source.phone != returned_dispensary_source['phone_number']
			existing_dispensary_source.update_attribute :phone, returned_dispensary_source['phone_number']
		end
		
		#hours
		if returned_dispensary_source['hours_of_operation'] != nil && returned_dispensary_source['hours_of_operation']['Weekly'] != nil

			hours_returned = returned_dispensary_source['hours_of_operation']['Weekly']
			
			#monday
			if hours_returned['Monday'] != nil
				dispensary_source.update_attribute :monday_open_time, hours_returned['Monday']['Open']
				dispensary_source.update_attribute :monday_close_time, hours_returned['Monday']['Close']
			end

			#tuesday
			if hours_returned['Tuesday'] != nil
				dispensary_source.update_attribute :tuesday_open_time, hours_returned['Tuesday']['Open']
				dispensary_source.update_attribute :tuesday_close_time, hours_returned['Tuesday']['Close']
			end

			#wednesday
			if hours_returned['Wednesday'] != nil
				dispensary_source.update_attribute :wednesday_open_time, hours_returned['Wednesday']['Open']
				dispensary_source.update_attribute :wednesday_close_time, hours_returned['Wednesday']['Close']
			end

			#thursday
			if hours_returned['Thursday'] != nil
				dispensary_source.update_attribute :thursday_open_time, hours_returned['Thursday']['Open']
				dispensary_source.update_attribute :thursday_close_time, hours_returned['Thursday']['Close']
			end

			#friday
			if hours_returned['Friday'] != nil
				dispensary_source.update_attribute :friday_open_time, hours_returned['Friday']['Open']
				dispensary_source.update_attribute :friday_close_time, hours_returned['Friday']['Close']
			end

			#saturday
			if hours_returned['Saturday'] != nil
				dispensary_source.update_attribute :saturday_open_time, hours_returned['Saturday']['Open']
				dispensary_source.update_attribute :saturday_close_time, hours_returned['Saturday']['Close']
			end

			#sunday
			if hours_returned['Sunday'] != nil
				dispensary_source.update_attribute :sunday_open_time, hours_returned['Sunday']['Open']
				dispensary_source.update_attribute :sunday_close_time, hours_returned['Sunday']['Close']
			end

		end #endHours 

	end #end compareAndUpdateDispensarySourceValues method

	
end #end of class