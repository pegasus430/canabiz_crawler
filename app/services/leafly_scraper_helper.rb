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
								includes(:dispensary, :products, :products => :vendors, :dispensary_source_products => :dsp_prices)

		#the actual dispensaries that we will really display
		@real_dispensaries = Dispensary.where(state_id: @state.id)

		#MAKE CALL AND CREATE JSON
		output = nil
		if @city_range.present?
            output = IO.popen(["python", "#{Rails.root}/app/scrapers/leafly_disp_scraper.py", @state_abbreviation, '--city='+ @city_range])
		else
            output = IO.popen(["python", "#{Rails.root}/app/scrapers/leafly_disp_scraper.py", @state_abbreviation])
		end

		contents = JSON.parse(output.read)

		#LOOP THROUGH CONTENTS RETURNED (DISPENSARIES)
		contents[@state_abbreviation.downcase].each do |returned_dispensary_source|
			
			#check if the dispensary source already exists
			existing_dispensary_sources = @dispensary_sources.select { |dispensary_source| dispensary_source.name.casecmp(returned_dispensary_source['name']) == 0 }
			
			if existing_dispensary_sources.size > 0 #DISPENSARY SOURCE ALREADY EXISTS
				
				#if exists, then I have to compare fields to see if any need to be updated
				compareAndUpdateDispensarySourceValues(returned_dispensary_source, existing_dispensary_sources[0])
				
				#loop through products and see if we need to create any or update any
				if returned_dispensary_source['menu'] != nil
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

		categoryToMenu = {
			#"Flower" => returned_json_menu['Flower'], 
			"Edibles" => returned_json_menu['Edible']
			#"Concentrates" => returned_json_menu['Concentrate'],
			#"Pre-Roll" => returned_json_menu['PreRoll'],
		}

		categoryToMenu.each do |category_name, returned_menu_section|
			
			@category_products = Category.where(name: category_name).first.products

			if returned_menu_section.present?

				#loop through the different menu sections (separated by title - category)
				returned_menu_section.each do |returned_dispensary_source_product|

					#IF ONE OF THE OTHER CATEGORIES - I WILL TAKE ALL OF THE PRODUCTS AND SEE IF THE 'NAME' CONTAINS THAT PRODUCT NAME (IGNORE CASE)

					#check if there is a strain - this is only for flower
					strain_name = nil
					if returned_dispensary_source_product['strain'].present? && returned_dispensary_source_product['strain']['name'].present?
						strain_name = returned_dispensary_source_product['strain']['name']
					end

					if strain_name != nil
						
						puts "THE STRAIN NAME IS NOT NIL: #{strain_name}"

						# check if dispensary source already has this product
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
							existing_products = @category_products.select { |product| product.name.casecmp(strain_name) == 0 }
							
							if existing_products.size > 0 #product is in the system
								
								#just create a dispensary source product
								createProductAndDispensarySourceProduct(existing_products[0], existing_dispensary_source.id, returned_dispensary_source_product)
				
							else #product is not in system
								
								#dive deeper for a match
								@category_products.each do |product|

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

					elsif returned_dispensary_source_product['name'].present? #strain_name = nil

						puts 'I AM IN HERE'
						#puts returned_dispensary_source_product

						#this is most likely the case for categories not flower
						@category_products.each do |cat_product|

							if returned_dispensary_source_product['name'].downcase.include? cat_product.name.downcase
								#consider this a product match

								puts 'I AM IN HERE 2'

								#see if this dispensary_source already has this product
								if is_new_dispensary == false && existing_dispensary_source.products.include?(cat_product)

									puts 'I AM IN HERE 3'

									# dispensary source has this product - just compare
									compareAndUpdateDispensarySourceProduct(returned_dispensary_source_product, DispensarySourceProduct.
																where(product: cat_product).where(dispensary_source: existing_dispensary_source).first, 
																existing_dispensary_source)

								else #dispensary source doesn't currently have this product - have to add it

									puts 'I AM IN HERE 4'
									
									#just create a dispensary source product
									createProductAndDispensarySourceProduct(cat_product, existing_dispensary_source.id, returned_dispensary_source_product)
								end

								break
							end
						end

					end #end of if statement to see if the strain name is null

				end #end loop of each section's products
			end #end if statement to see if the section is not nil

		end #end loop of each menu 'section' -> sections are broken down by type 'indica, sativa, et

	end #analyzeReturnedDispensarySourceMenu 

	#method to create product (if necessary) and dispensary product
	def createProductAndDispensarySourceProduct(product, dispensary_source_id, returned_dispensary_source_product)

		#if our product has no image, lets take their image:
		if product.remote_image_url == nil && returned_dispensary_source_product['imageUrl'] && returned_dispensary_source_product['imageUrl'].length < 150
			product.update_attribute :remote_image_url, returned_dispensary_source_product['imageUrl']
		end
		
		#if no description, lets take their description: 
		if product.description == nil && returned_dispensary_source_product['description'].present?
			product.update_attribute :description, returned_dispensary_source_product['description']
		end

		#create a product state if it doesn't exist
		if ProductState.where(product_id: product.id).where(state_id: @state.id).empty?
			ProductState.create(
				:product_id => product.id,
				:state_id => @state.id,
			)
		end


		#map of their quantities to our quantities
		quantityToQuantity = {
			'1 g' => 'Gram',	
			'2 g' => '2 Grams',	
			'⅛ oz' => 'Eighth',	
			'¼ oz' => 'Quarter Ounce',
			'½ oz' => 'Half Ounce',
			'1 oz' => 'Ounce',
			'each' => 'Each'
		}

		#create dispensary source product
		if returned_dispensary_source_product['prices'] != nil
			
			dsp = DispensarySourceProduct.create(:product_id => product.id, 
				:dispensary_source_id => dispensary_source_id)

			returned_dispensary_source_product['prices'].each do |quantity_price_pair|

				#only create if the quantity matches - if not we should email to create a new quantity
				if quantityToQuantity.has_key?(quantity_price_pair['quantity'])
					DspPrice.create(
						:dispensary_source_product_id => dsp.id,
						:unit => quantityToQuantity[quantity_price_pair['quantity']],
						:price => quantity_price_pair['price']
					)
				end
			end
		end

	end #end createProductAndDispensarySourceProduct method

	#method to compare returned dispensary product with one existing in system to see if prices need update
	def compareAndUpdateDispensarySourceProduct(returned_dispensary_source_product, existing_dispensary_source_product, existing_dispensary_source)
		
		if  returned_dispensary_source_product['prices'] != nil
			#see if we need to update the last_menu_update for the dispensary source
			updated_menu = false

			#need more for other categories
			quantityToQuantity = {
				'1 g' => 'Gram',	
				'2 g' => '2 Grams',	
				'⅛ oz' => 'Eighth',	
				'¼ oz' => 'Quarter Ounce',
				'½ oz' => 'Half Ounce',
				'1 oz' => 'Ounce',
				'each' => 'Each'
			}

			returned_dispensary_source_product['prices'].each do |quantity_price_pair|

				#use the same map like above - only update if we have a match
				if quantityToQuantity.has_key?(quantity_price_pair['quantity'])
					#see if we have any dsp prices with this quantity

					if existing_dispensary_source_product.dsp_prices.where(unit: quantityToQuantity[quantity_price_pair['quantity']]).any?
						#compare the price - if its different we update
						if existing_dispensary_source_product.dsp_prices.where(unit: quantityToQuantity[quantity_price_pair['quantity']]).first.price != quantity_price_pair['price']
							
							existing_dispensary_source_product.dsp_prices.
								where(unit: quantityToQuantity[quantity_price_pair['quantity']]).first.update_attribute :price, quantity_price_pair['price']
							
							updated_menu = true
						end
					else
						#create new dsp price
						DspPrice.create(
							:dispensary_source_product_id => existing_dispensary_source_product.id,
							:unit => quantityToQuantity[quantity_price_pair['quantity']],
							:price => quantity_price_pair['price']
						)
						updated_menu = true
					end

				end
			end
			
			#update the last_menu_update of the dispensary_source
			if updated_menu
				existing_dispensary_source.update_attribute :last_menu_update, DateTime.now
			end
			
			
		end #end of check to see if returned_dispensary_product['prices'] != nil
	end

	#method to create a dispensary (maybe) and dispensarySource record and its products (definitely)
	def createDispensaryAndDispensarySourceAndProducts(dispensary_id, returned_dispensary_source)
	
		image_url = returned_dispensary_source['avatar_url'].present? && returned_dispensary_source['avatar_url'].length < 150 ? 
						returned_dispensary_source['avatar_url'] : ''
		
		if dispensary_id == nil
			#create dispensary - I SHOULD MOVE ABOUT FIELD TO DISPENSARY SOURCE? 
			dispensary = Dispensary.create(
				:name => returned_dispensary_source['name'], 
				:state_id => @state.id, 
				:remote_image_url => image_url,
				:about => returned_dispensary_source['about-dispensary']
			)
			dispensary_id = dispensary.id
		end
	
		dispensary_source = DispensarySource.create(:dispensary_id => dispensary_id, :source_id => @source.id, :state_id => @state.id,
								:name => returned_dispensary_source["name"], :city => returned_dispensary_source['city'],
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
		if existing_dispensary_source.remote_image_url == nil && returned_dispensary_source['avatar_url'].present? && returned_dispensary_source['avatar_url'].length < 150 
			existing_dispensary_source.update_attribute :remote_image_url, returned_dispensary_source['avatar_url']
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