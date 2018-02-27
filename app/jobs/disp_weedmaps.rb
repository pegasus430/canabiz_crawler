class DispWeedmaps < ActiveJob::Base
	include SuckerPunch::Job
	
	def perform(state_name, city_range)
		@state_name = state_name
		@city_range = city_range
		logger.info "Weedmaps Job is running"
		scrapeWeedmaps()  
	end
	
	def scrapeWeedmaps()
		
		#GLOBAL VARIABLES
		@source = Source.where(name: 'Weed Maps').first #source we are scraping
		@state = State.where(name: @state_name).first #state we are scraping from the source
				
		#query the dispensarysources from this source and this state that have a dispensary lookup
		@dispensary_sources = DispensarySource.where(state_id: @state.id).where(source_id: @source.id).
								includes(:dispensary, :products, :products => :vendors)
		
		#the actual dispensaries that we will really display
		@real_dispensaries = Dispensary.where(state_id: @state.id)
								
		#query all featured products to look for a match
		@flower_products = Category.where(name: 'Flower').first.products.featured.includes(:vendors)
		#@all_products = Product.featured
		
		#MAKE CALL AND CREATE JSON
		require "json"
		output = nil
		if @city_range.present?
            output = IO.popen(["python", "#{Rails.root}/app/scrapers/weedmaps_disp_scraper.py", @state_name, '-city='+ @city_range])
		else
            output = IO.popen(["python", "#{Rails.root}/app/scrapers/weedmaps_disp_scraper.py", @state_name])
		end
		contents = JSON.parse(output.read)
		
		logger.info contents[0]
		contents.clear
		
		#LOOP THROUGH CONTENTS RETURNED (DISPENSARIES)
		contents.each do |returned_dispensary_source|
			
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
	
		returned_json_menu.each do |returned_menu_section|

			#right now we are only doing flowers
			if ['Indica', 'Hybrid', 'Sativa', 'Flower'].include? returned_menu_section['title']
			
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
											existing_dispensary_source_products.add(product)
											break
										end
									end
								end

								#check products with vendor name
								if product.vendors.any?
									product.vendors.each do |vendor|
										combined = "#{product.name} - #{vendor.name}"
										if combined.casecmp(returned_dispensary_source_product['name']) == 0
											existing_dispensary_source_products.add(product)
											break
										end
									end
								end

							end
						end

					end
					
					if existing_dispensary_source_products.size > 0 #dispensary source has the product
						
						#if product already exists, check to see if any prices have changed
						compareAndUpdateDispensarySourceProduct(returned_dispensary_source_product, DispensarySourceProduct.
															where(product: existing_dispensary_source_products[0]).
															where(dispensary_source: existing_dispensary_source).first, existing_dispensary_source)
					
					else #dispensary source does not have the product / it is a new dispensary source
						
						#first check if product is in the system - used to be all_products
						existing_products = @flower_products.select { |product| product.name.casecmp(returned_dispensary_source_product['name']) == 0 }
						
						if existing_products.size > 0 #product is in the system
							
							#just create a dispensary source product
							createProductAndDispensarySourceProduct(existing_products[0], 
								existing_dispensary_source.id, returned_dispensary_source_product)
			
							#existing_dispensary_source.update_attribute :last_menu_update, DateTime.now
						else
							#dive deeper for a match
							@flower_products.each do |product|
								if existing_products.size > 0 
									createProductAndDispensarySourceProduct(existing_products[0], 
											existing_dispensary_source.id, returned_dispensary_source_product)
									break
								end 

								#check alternate names for a match
								if product.alternate_names.present? 
									product.alternate_names.split(',').each do |alt|
										if alt.name.casecmp(returned_dispensary_source_product['name']) == 0
											existing_products.add(product)
											break
										end
									end
								end

								#check products with vendor name
								if product.vendors.any?
									product.vendors.each do |vendor|
										combined = "#{product.name} - #{vendor.name}"
										if combined.casecmp(returned_dispensary_source_product['name']) == 0
											existing_products.add(product)
											break
										end
									end
								end
							end
						end
						
						#either way I update the dispensarySource.last_menu_update
						existing_dispensary_source.update_attribute :last_menu_update, DateTime.now
						
					end
				end #end loop of each section's products
			end #end if statement to check if product is a flower - will need to update in future
			
		end #end loop of each menu 'section' -> sections are broken down by type 'indica, sativa, etc'
	
	end #end analyzeReturnedDispensarySourceMenu method
	
	#method to create product (if necessary) and dispensary product
	def createProductAndDispensarySourceProduct(product, dispensary_source_id, returned_dispensary_source_product)

		#create dispensary source product
		if returned_dispensary_source_product['prices'] != nil
			DispensarySourceProduct.create(:product_id => product.id, 
				:dispensary_source_id => dispensary_source_id,
				:remote_image_url => returned_dispensary_source_product['image_url'],
				:price => returned_dispensary_source_product['prices']['unit'], 
				:price_half_gram => returned_dispensary_source_product['prices']['half_gram'],
				:price_gram => returned_dispensary_source_product['prices']['gram'],
				:price_two_grams => returned_dispensary_source_product['prices']['two_grams'],
				:price_eighth => returned_dispensary_source_product['prices']['eighth'],
				:price_quarter => returned_dispensary_source_product['prices']['quarter'],
				:price_half_ounce => returned_dispensary_source_product['prices']['half_ounce'],
				:price_ounce => returned_dispensary_source_product['prices']['ounce']
			)
			
			if returned_dispensary_source_product['prices']['unit'] != nil && returned_dispensary_source_product['prices']['unit'] != 0.0
				product.update_attribute :product_type, 'Other'
			end 
		end


	end #end createProductAndDispensarySourceProduct method

	#method to compare returned dispensary product with one existing in system to see if prices need update
	def compareAndUpdateDispensarySourceProduct(returned_dispensary_source_product, existing_dispensary_source_product, dispensary_source)
		
		#image
		if existing_dispensary_source_product.image != returned_dispensary_source_product['image_url']
			existing_dispensary_source_product.update_attribute :image, returned_dispensary_source_product['image_url']
		end
		
		if  returned_dispensary_source_product['prices'] != nil
			#see if we need to update the last_menu_update for the dispensary source
			updated_menu = false
			
			#unit = just 1 (standard for edibles and such I would think)
			if existing_dispensary_source_product.price != returned_dispensary_source_product['prices']['unit']
				existing_dispensary_source_product.update_attribute :price, returned_dispensary_source_product['prices']['unit']
				updated_menu = true
			end
	
			#price_half_gram
			if existing_dispensary_source_product.price_half_gram != returned_dispensary_source_product['prices']['half_gram']
				existing_dispensary_source_product.update_attribute :price_half_gram, returned_dispensary_source_product['prices']['half_gram']
				updated_menu = true
			end
			
			#gram
			if existing_dispensary_source_product.price_gram != returned_dispensary_source_product['prices']['gram']
				existing_dispensary_source_product.update_attribute :price_gram, returned_dispensary_source_product['prices']['gram']
				updated_menu = true
			end
			
			#price_two_grams
			if existing_dispensary_source_product.price_two_grams != returned_dispensary_source_product['prices']['two_grams']
				existing_dispensary_source_product.update_attribute :price_two_grams, returned_dispensary_source_product['prices']['two_grams']
				updated_menu = true
			end
			
			#price_eighth
			if existing_dispensary_source_product.price_eighth != returned_dispensary_source_product['prices']['eighth']
				existing_dispensary_source_product.update_attribute :price_eighth, returned_dispensary_source_product['prices']['eighth']
				updated_menu = true
			end
			
			#price_quarter
			if existing_dispensary_source_product.price_quarter != returned_dispensary_source_product['prices']['quarter']
				existing_dispensary_source_product.update_attribute :price_quarter, returned_dispensary_source_product['prices']['quarter']
				updated_menu = true
			end 
			
			#price_half_ounce
			if existing_dispensary_source_product.price_half_ounce != returned_dispensary_source_product['prices']['half_ounce']
				existing_dispensary_source_product.update_attribute :price_half_ounce, returned_dispensary_source_product['prices']['half_ounce']
				updated_menu = true
			end
			
			#price_ounce
			if existing_dispensary_source_product.price_ounce != returned_dispensary_source_product['prices']['ounce']
				existing_dispensary_source_product.update_attribute :price_ounce, returned_dispensary_source_product['prices']['ounce']
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
								:remote_image_url => returned_dispensary_source['avatar_url']
							)
			dispensary_id = dispensary.id
		end
	
		dispensary_source = DispensarySource.create(:dispensary_id => dispensary_id, :source_id => @source.id, :state_id => @state.id,
								:name => returned_dispensary_source["name"], :location => location, :city => returned_dispensary_source['city'],
								:street => returned_dispensary_source["address"], :zip_code => returned_dispensary_source["zip_code"],
								:source_rating => returned_dispensary_source['rating'], :email => returned_dispensary_source['email'], 
								:phone => returned_dispensary_source['phone'], :website => returned_dispensary_source['website'],
								:remote_image_url => returned_dispensary_source['avatar_url']
							)  

		#hours
		if returned_dispensary_source['hours_of_operation'] != nil
			
			#monday
			if returned_dispensary_source['hours_of_operation']['monday'].include? '-'
				dispensary_source.update_attribute :monday_open_time, 
					returned_dispensary_source['hours_of_operation']['monday'].partition('-').first.strip.to_time
				dispensary_source.update_attribute :monday_close_time,
					returned_dispensary_source['hours_of_operation']['monday'].partition('-').last.strip.to_time
			end

			#tuesday
			if returned_dispensary_source['hours_of_operation']['tuesday'].include? '-'
				dispensary_source.update_attribute :tuesday_open_time, 
					returned_dispensary_source['hours_of_operation']['tuesday'].partition('-').first.strip.to_time
				dispensary_source.update_attribute :tuesday_close_time,
					returned_dispensary_source['hours_of_operation']['tuesday'].partition('-').last.strip.to_time
			end

			#wednesday
			if returned_dispensary_source['hours_of_operation']['wednesday'].include? '-'
				dispensary_source.update_attribute :wednesday_open_time, 
					returned_dispensary_source['hours_of_operation']['wednesday'].partition('-').first.strip.to_time
				dispensary_source.update_attribute :wednesday_close_time,
					returned_dispensary_source['hours_of_operation']['wednesday'].partition('-').last.strip.to_time
			end

			#thursday
			if returned_dispensary_source['hours_of_operation']['thursday'].include? '-'
				dispensary_source.update_attribute :thursday_open_time, 
					returned_dispensary_source['hours_of_operation']['thursday'].partition('-').first.strip.to_time
				dispensary_source.update_attribute :thursday_close_time,
					returned_dispensary_source['hours_of_operation']['thursday'].partition('-').last.strip.to_time
			end

			#friday
			if returned_dispensary_source['hours_of_operation']['friday'].include? '-'
				dispensary_source.update_attribute :friday_open_time, 
					returned_dispensary_source['hours_of_operation']['friday'].partition('-').first.strip.to_time
				dispensary_source.update_attribute :friday_close_time,
					returned_dispensary_source['hours_of_operation']['friday'].partition('-').last.strip.to_time
			end

			#saturday
			if returned_dispensary_source['hours_of_operation']['saturday'].include? '-'
				dispensary_source.update_attribute :saturday_open_time, 
					returned_dispensary_source['hours_of_operation']['saturday'].partition('-').first.strip.to_time
				dispensary_source.update_attribute :saturday_close_time,
					returned_dispensary_source['hours_of_operation']['saturday'].partition('-').last.strip.to_time
			end

			#sunday
			if returned_dispensary_source['hours_of_operation']['sunday'].include? '-'
				dispensary_source.update_attribute :sunday_open_time, 
					returned_dispensary_source['hours_of_operation']['sunday'].partition('-').first.strip.to_time
				dispensary_source.update_attribute :sunday_close_time,
					returned_dispensary_source['hours_of_operation']['sunday'].partition('-').last.strip.to_time
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
		
		#details
		if returned_dispensary_source['details'] != nil
			
			#website
			if existing_dispensary_source.website != returned_dispensary_source['details']['website']
				existing_dispensary_source.update_attribute :website, returned_dispensary_source['details']['website']
			end
			
			#facebook
			if existing_dispensary_source.facebook != returned_dispensary_source['details']['facebook']
				existing_dispensary_source.update_attribute :facebook, returned_dispensary_source['details']['facebook']
			end
			
			#instagram
			if existing_dispensary_source.instagram != returned_dispensary_source['details']['instagram']
				existing_dispensary_source.update_attribute :instagram, returned_dispensary_source['details']['instagram']
			end
			
			#twitter
			if existing_dispensary_source.twitter != returned_dispensary_source['details']['twitter']
				existing_dispensary_source.update_attribute :twitter, returned_dispensary_source['details']['twitter']
			end
			
			#age 
			if returned_dispensary_source['details']['age'] != nil
				min_age = nil
				if returned_dispensary_source['details']['age'].include? '18'
					min_age = 18
				elsif returned_dispensary_source['details']['age'].include? '21'
					min_age = 21
				end
				
				if existing_dispensary_source.min_age != min_age
					existing_dispensary_source.update_attribute :min_age, min_age
				end
			end
		end
		
		#hours - need to break the strings
		if returned_dispensary_source['hours_of_operation'] != nil
		
			#monday
			if returned_dispensary_source['hours_of_operation']['monday'].include? '-'
				monday_open = returned_dispensary_source['hours_of_operation']['monday'].partition('-').first.strip.to_time
				monday_close = returned_dispensary_source['hours_of_operation']['monday'].partition('-').last.strip.to_time
				
				if existing_dispensary_source.monday_open_time != nil
					if existing_dispensary_source.monday_open_time.utc.strftime( "%H%M%S%N" ) != monday_open.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :monday_open_time, monday_open
					end
				else 
					existing_dispensary_source.update_attribute :monday_open_time, monday_open
				end
				
				
				if existing_dispensary_source.monday_close_time != nil
					if existing_dispensary_source.monday_close_time.utc.strftime( "%H%M%S%N" ) != monday_close.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :monday_close_time, monday_close
					end
				else 
					existing_dispensary_source.update_attribute :monday_close_time, monday_close
				end
			end

			#tuesday
			if returned_dispensary_source['hours_of_operation']['tuesday'].include? '-'
				tuesday_open = returned_dispensary_source['hours_of_operation']['tuesday'].partition('-').first.strip.to_time
				tuesday_close = returned_dispensary_source['hours_of_operation']['tuesday'].partition('-').last.strip.to_time
				
				if existing_dispensary_source.tuesday_open_time != nil
					if existing_dispensary_source.tuesday_open_time.utc.strftime( "%H%M%S%N" ) != tuesday_open.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :tuesday_open_time, tuesday_open
					end
				else 
					existing_dispensary_source.update_attribute :tuesday_open_time, tuesday_open
				end
				
				
				if existing_dispensary_source.tuesday_close_time != nil
					if existing_dispensary_source.tuesday_close_time.utc.strftime( "%H%M%S%N" ) != tuesday_close.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :tuesday_close_time, tuesday_close
					end
				else 
					existing_dispensary_source.update_attribute :tuesday_close_time, tuesday_close
				end
			end

			#wednesday
			if returned_dispensary_source['hours_of_operation']['wednesday'].include? '-'
				wednesday_open = returned_dispensary_source['hours_of_operation']['wednesday'].partition('-').first.strip.to_time
				wednesday_close = returned_dispensary_source['hours_of_operation']['wednesday'].partition('-').last.strip.to_time
				
				if existing_dispensary_source.wednesday_open_time != nil
					if existing_dispensary_source.wednesday_open_time.utc.strftime( "%H%M%S%N" ) != wednesday_open.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :wednesday_open_time, wednesday_open
					end
				else 
					existing_dispensary_source.update_attribute :wednesday_open_time, wednesday_open
				end
				
				
				if existing_dispensary_source.wednesday_close_time != nil
					if existing_dispensary_source.wednesday_close_time.utc.strftime( "%H%M%S%N" ) != wednesday_close.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :wednesday_close_time, wednesday_close
					end
				else 
					existing_dispensary_source.update_attribute :wednesday_close_time, wednesday_close
				end
			end

			#thursday
			if returned_dispensary_source['hours_of_operation']['thursday'].include? '-'
				thursday_open = returned_dispensary_source['hours_of_operation']['thursday'].partition('-').first.strip.to_time
				thursday_close = returned_dispensary_source['hours_of_operation']['thursday'].partition('-').last.strip.to_time
				
				if existing_dispensary_source.thursday_open_time != nil
					if existing_dispensary_source.thursday_open_time.utc.strftime( "%H%M%S%N" ) != thursday_open.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :thursday_open_time, thursday_open
					end
				else 
					existing_dispensary_source.update_attribute :thursday_open_time, thursday_open
				end
				
				
				if existing_dispensary_source.thursday_close_time != nil
					if existing_dispensary_source.thursday_close_time.utc.strftime( "%H%M%S%N" ) != thursday_close.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :thursday_close_time, thursday_close
					end
				else 
					existing_dispensary_source.update_attribute :thursday_close_time, thursday_close
				end
			end

			#friday
			if returned_dispensary_source['hours_of_operation']['friday'].include? '-'
				friday_open = returned_dispensary_source['hours_of_operation']['friday'].partition('-').first.strip.to_time
				friday_close = returned_dispensary_source['hours_of_operation']['friday'].partition('-').last.strip.to_time
				
				if existing_dispensary_source.friday_open_time != nil
					if existing_dispensary_source.friday_open_time.utc.strftime( "%H%M%S%N" ) != friday_open.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :friday_open_time, friday_open
					end
				else 
					existing_dispensary_source.update_attribute :friday_open_time, friday_open
				end
				
				
				if existing_dispensary_source.friday_close_time != nil
					if existing_dispensary_source.friday_close_time.utc.strftime( "%H%M%S%N" ) != friday_close.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :friday_close_time, friday_close
					end
				else 
					existing_dispensary_source.update_attribute :friday_close_time, friday_close
				end
			end

			#saturday
			if returned_dispensary_source['hours_of_operation']['saturday'].include? '-'
				saturday_open = returned_dispensary_source['hours_of_operation']['saturday'].partition('-').first.strip.to_time
				saturday_close = returned_dispensary_source['hours_of_operation']['saturday'].partition('-').last.strip.to_time
				
				if existing_dispensary_source.saturday_open_time != nil
					if existing_dispensary_source.saturday_open_time.utc.strftime( "%H%M%S%N" ) != saturday_open.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :saturday_open_time, saturday_open
					end
				else 
					existing_dispensary_source.update_attribute :saturday_open_time, saturday_open
				end
				
				
				if existing_dispensary_source.saturday_close_time != nil
					if existing_dispensary_source.saturday_close_time.utc.strftime( "%H%M%S%N" ) != saturday_close.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :saturday_close_time, saturday_close
					end
				else 
					existing_dispensary_source.update_attribute :saturday_close_time, saturday_close
				end
			end

			#sunday
			if returned_dispensary_source['hours_of_operation']['sunday'].include? '-'
				sunday_open = returned_dispensary_source['hours_of_operation']['sunday'].partition('-').first.strip.to_time
				sunday_close = returned_dispensary_source['hours_of_operation']['sunday'].partition('-').last.strip.to_time
				
				if existing_dispensary_source.sunday_open_time != nil
					if existing_dispensary_source.sunday_open_time.utc.strftime( "%H%M%S%N" ) != sunday_open.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :sunday_open_time, sunday_open
					end
				else 
					existing_dispensary_source.update_attribute :sunday_open_time, sunday_open
				end
				
				
				if existing_dispensary_source.sunday_close_time != nil
					if existing_dispensary_source.sunday_close_time.utc.strftime( "%H%M%S%N" ) != sunday_close.utc.strftime( "%H%M%S%N" )
						existing_dispensary_source.update_attribute :sunday_close_time, sunday_close
					end
				else 
					existing_dispensary_source.update_attribute :sunday_close_time, sunday_close
				end
			end
		end #end of hours 

	end #end compareAndUpdateDispensarySourceValues method
	
end #end of class