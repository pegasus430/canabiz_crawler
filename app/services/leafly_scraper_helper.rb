class LeaflyScraperHelper

	attr_reader :state_abbreviation, :city_range
	
	def initialize(state_abbreviation, city_range)
		@state_abbreviation = state_abbreviation
		@city_range = city_range
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
		#logger.info contents['wa'][0]
		#contents.clear

		#LOOP THROUGH CONTENTS RETURNED (DISPENSARIES)
		contents['wa'].each do |returned_dispensary_source|
			
			#check if the dispensary source already exists
			existing_dispensary_sources = @dispensary_sources.select { |dispensary_source| dispensary_source.name.casecmp(returned_dispensary_source['name']) == 0 }
			
			if existing_dispensary_sources.size > 0 #DISPENSARY SOURCE ALREADY EXISTS
				
				#if exists, then I have to compare fields to see if any need to be updated
				compareAndUpdateDispensarySourceValues(returned_dispensary_source, existing_dispensary_sources[0])
				
				#loop through products and see if we need to create any or update any
				if returned_dispensary_source['menu'] != nil #&& returned_dispensary_source['info']['menu'] != nil
					analyzeReturnedDispensarySourceMenu(returned_dispensary_source['menu'], existing_dispensary_sources[0], false)
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

		valid_menu_sections = []
		valid_menu_sections.push(returned_json_menu['Flower'])

		valid_menu_sections.each do |returned_menu_section|

			#right now we are only doing flowers
			#if ['Flowers', 'Indicas', 'Sativas', 'Hybrids'].include? returned_menu_section['name']
			if returned_menu_section.present?

				#loop through the different menu sections (separated by title - category)
				returned_menu_section.each do |returned_dispensary_source_product|

					#check if there is a strain
					strain_name = nil
					if returned_dispensary_source_product['strain'] != nil && returned_dispensary_source_product['strain']['name'] != nil
						strain_name = returned_dispensary_source_product['strain']['name']
					end

					puts 'STRAIN NAME: '
					puts strain_name

					if strain_name != nil

						#check if dispensary source already has this product
						existing_dispensary_source_products = []

						#if its not a new dispensary, we will check if the dispensary source already has the product
						if is_new_dispensary == false
							existing_dispensary_source_products = existing_dispensary_source.products.select { |product| 
																	product.name.casecmp(strain_name) == 0 }

							#try alternate names or combine with vendors
							if existing_dispensary_source_products.size == 0
								existing_dispensary_source.products.each do |product|
									
									#check alternate names for a match
									if product.alternate_names.present? 
										product.alternate_names.split(',').each do |alt|
											if alt.casecmp(strain_name) == 0
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
																where(dispensary_source: existing_dispensary_source).first, 
																existing_dispensary_source)
						
						else #dispensary source does not have the product / it is a new dispensary source

							#first check if product is in the system	
							existing_products = @flower_products.select { |product| product.name.casecmp(strain_name) == 0 }
							
							if existing_products.size > 0 #product is in the system
								
								#just create a dispensary source product
								createProductAndDispensarySourceProduct(existing_products[0], existing_dispensary_source.id, returned_dispensary_source_product)
				
							else #product is not in system
								
								#dive deeper for a match
								@flower_products.each do |product|

									#check alternate names for a match
									if product.alternate_names.present? 
										product.alternate_names.split(',').each do |alt|
											if alt.casecmp(strain_name) == 0
												existing_products.push(product)
												break
											end
										end
									end

									if existing_products.size > 0 #product is in the system
										createProductAndDispensarySourceProduct(existing_products[0], existing_dispensary_source.id, returned_dispensary_source_product)
									end
								end #end of deep dive

							end		
							
							#either way I update the dispensarySource.last_menu_update
							existing_dispensary_source.update_attribute :last_menu_update, DateTime.now
							
						end

					end #end of if statement to see if the strain name is null

				end #end loop of each section's products
			end #end if statement to see if the section is not nil

		end #end loop of each menu 'section' -> sections are broken down by type 'indica, sativa, et

	end #analyzeReturnedDispensarySourceMenu 

	#method to create product (if necessary) and dispensary product
	def createProductAndDispensarySourceProduct(product, dispensary_source_id, returned_dispensary_source_product)

		#create dispensary source product
		if returned_dispensary_source_product['prices'] != nil

			#get all of the prices:
			price_gram = nil
			price_two_grams = nil
			price_eighth = nil
			price_quarter = nil
			price_half_ounce = nil
			price_ounce = nil

			returned_dispensary_source_product['prices'].each do |quantity_price_pair|

				if quantity_price_pair['quantity'] == '1 g'
					price_gram = quantity_price_pair['price']

				elsif quantity_price_pair['quantity'] == '2 g'
					price_two_grams = quantity_price_pair['price']

				elsif quantity_price_pair['quantity'] == '⅛ oz'
					price_eighth = quantity_price_pair['price']

				elsif quantity_price_pair['quantity'] == '¼ oz'
					price_quarter = quantity_price_pair['price']

				elsif quantity_price_pair['quantity'] == '½ oz'
					price_half_ounce = quantity_price_pair['price']

				elsif quantity_price_pair['quantity'] == '1 oz'
					price_ounce = quantity_price_pair['price']

				end
			end

			DispensarySourceProduct.create(:product_id => product.id, 
				:dispensary_source_id => dispensary_source_id,
				:price_gram => price_gram,
				:price_two_grams => price_two_grams,
				:price_eighth => price_eighth,
				:price_quarter => price_quarter,
				:price_half_ounce => price_half_ounce,
				:price_ounce => price_ounce
			)
			
		end

	end #end createProductAndDispensarySourceProduct method

	#method to compare returned dispensary product with one existing in system to see if prices need update
	def compareAndUpdateDispensarySourceProduct(returned_dispensary_source_product, existing_dispensary_source_product, existing_dispensary_source)
		
		if  returned_dispensary_source_product['prices'] != nil
			#see if we need to update the last_menu_update for the dispensary source
			updated_menu = false
			
			#get all of the prices:
			price_gram = nil
			price_two_grams = nil
			price_eighth = nil
			price_quarter = nil
			price_half_ounce = nil
			price_ounce = nil

			returned_dispensary_source_product['prices'].each do |quantity_price_pair|

				if quantity_price_pair['quantity'] == '1 g'
					price_gram = quantity_price_pair['price']

				elsif quantity_price_pair['quantity'] == '2 g'
					price_two_grams = quantity_price_pair['price']

				elsif quantity_price_pair['quantity'] == '⅛ oz'
					price_eighth = quantity_price_pair['price']

				elsif quantity_price_pair['quantity'] == '¼ oz'
					price_quarter = quantity_price_pair['price']

				elsif quantity_price_pair['quantity'] == '½ oz'
					price_half_ounce = quantity_price_pair['price']

				elsif quantity_price_pair['quantity'] == '1 oz'
					price_ounce = quantity_price_pair['price']

				end
			end
			
			#gram
			if existing_dispensary_source_product.price_gram != price_gram
				existing_dispensary_source_product.update_attribute :price_gram, price_gram
				updated_menu = true
			end
			
			#price_two_grams
			if existing_dispensary_source_product.price_two_grams != price_two_grams
				existing_dispensary_source_product.update_attribute :price_two_grams, price_two_grams
				updated_menu = true
			end
			
			#price_eighth
			if existing_dispensary_source_product.price_eighth != price_eighth
				existing_dispensary_source_product.update_attribute :price_eighth, price_eighth
				updated_menu = true
			end
			
			#price_quarter
			if existing_dispensary_source_product.price_quarter != price_quarter
				existing_dispensary_source_product.update_attribute :price_quarter, price_quarter
				updated_menu = true
			end 
			
			#price_half_ounce
			if existing_dispensary_source_product.price_half_ounce != price_half_ounce
				existing_dispensary_source_product.update_attribute :price_half_ounce, price_half_ounce
				updated_menu = true
			end
			
			#price_ounce
			if existing_dispensary_source_product.price_ounce != price_ounce
				existing_dispensary_source_product.update_attribute :price_ounce, price_ounce
				updated_menu = true
			end

			
			#update the last_menu_update of the dispensary_source
			if updated_menu
				existing_dispensary_source.update_attribute :last_menu_update, DateTime.now
			end
			
			
		end #end of check to see if returned_dispensary_product['prices'] != nil
	end

	#method to create a dispensary (maybe) and dispensarySource record and its products (definitely)
	def createDispensaryAndDispensarySourceAndProducts(dispensary_id, returned_dispensary_source)
	
		location = returned_dispensary_source['address'] + ', ' + returned_dispensary_source['city'] + ', ' + 
							returned_dispensary_source['state'] + ' ' + returned_dispensary_source['zip_code']
	
		image_url = returned_dispensary_source['avatar_url'].present? && returned_dispensary_source['avatar_url'].length < 150 ? 
						returned_dispensary_source['avatar_url'] : ''
		if dispensary_id == nil
			#create dispensary
			dispensary = Dispensary.create(:name => returned_dispensary_source['name'], 
								:state_id => @state.id, :location => location, :city => returned_dispensary_source['city'],
								:remote_image_url => image_url,
								:about => returned_dispensary_source['about-dispensary']
							)
			dispensary_id = dispensary.id
		end
	
		dispensary_source = DispensarySource.create(:dispensary_id => dispensary_id, :source_id => @source.id, :state_id => @state.id,
								:name => returned_dispensary_source["name"], :location => location, :city => returned_dispensary_source['city'],
								:street => returned_dispensary_source["address"], :zip_code => returned_dispensary_source["zip_code"],
								:source_rating => returned_dispensary_source['rating'], 
								:phone => returned_dispensary_source['phone_number'], :website => returned_dispensary_source['website'],
								:remote_image_url => image_url
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
		if returned_dispensary_source['menu'] != nil
			analyzeReturnedDispensarySourceMenu(returned_dispensary_source['menu'], dispensary_source, true)
		end
	
	end #end createDispensaryAndDispensarySourceAndProducts method

	#method to compare new dispensary from scraper with dispensary in system to see if any fields need to be updated
	def compareAndUpdateDispensarySourceValues(returned_dispensary_source, existing_dispensary_source)
	
		#image
		if existing_dispensary_source.remote_image_url != returned_dispensary_source['avatar_url'] && returned_dispensary_source['avatar_url'].present? && returned_dispensary_source['avatar_url'].length < 150 
			existing_dispensary_source.update_attribute :remote_image_url, returned_dispensary_source['avatar_url']
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
				existing_dispensary_source.update_attribute :monday_open_time, hours_returned['Monday']['Open']
				existing_dispensary_source.update_attribute :monday_close_time, hours_returned['Monday']['Close']
			end

			#tuesday
			if hours_returned['Tuesday'] != nil
				existing_dispensary_source.update_attribute :tuesday_open_time, hours_returned['Tuesday']['Open']
				existing_dispensary_source.update_attribute :tuesday_close_time, hours_returned['Tuesday']['Close']
			end

			#wednesday
			if hours_returned['Wednesday'] != nil
				existing_dispensary_source.update_attribute :wednesday_open_time, hours_returned['Wednesday']['Open']
				existing_dispensary_source.update_attribute :wednesday_close_time, hours_returned['Wednesday']['Close']
			end

			#thursday
			if hours_returned['Thursday'] != nil
				existing_dispensary_source.update_attribute :thursday_open_time, hours_returned['Thursday']['Open']
				existing_dispensary_source.update_attribute :thursday_close_time, hours_returned['Thursday']['Close']
			end

			#friday
			if hours_returned['Friday'] != nil
				existing_dispensary_source.update_attribute :friday_open_time, hours_returned['Friday']['Open']
				existing_dispensary_source.update_attribute :friday_close_time, hours_returned['Friday']['Close']
			end

			#saturday
			if hours_returned['Saturday'] != nil
				existing_dispensary_source.update_attribute :saturday_open_time, hours_returned['Saturday']['Open']
				existing_dispensary_source.update_attribute :saturday_close_time, hours_returned['Saturday']['Close']
			end

			#sunday
			if hours_returned['Sunday'] != nil
				existing_dispensary_source.update_attribute :sunday_open_time, hours_returned['Sunday']['Open']
				existing_dispensary_source.update_attribute :sunday_close_time, hours_returned['Sunday']['Close']
			end

		end #endHours 

	end #end compareAndUpdateDispensarySourceValues method
	
end #end of class