class WMProductStillExistsHelper
	
	attr_reader :state_name, :city_range
	
	def initialize(state_name, city_range)
		@state_name = state_name
		@city_range = city_range
	end
	
	def scrapeWeedmaps()
		
		#GLOBAL VARIABLES
		@source = Source.where(name: 'Weed Maps').first #source we are scraping
		@state = State.where(name: @state_name).first #state we are scraping from the source
				
		#query the dispensarysources from this source and this state that have a dispensary lookup
		@dispensary_sources = DispensarySource.where(state_id: @state.id).where(source_id: @source.id).
								includes(:products, :dispensary_source_products)
		
								
		#query all featured products by category to look for a match - add in other product lists as needed
		@flower_products = Category.where(name: 'Flower').first.products.featured.includes(:vendors)
		#@all_products = Product.featured
		
		#MAKE CALL AND CREATE JSON
		require "json"
		require 'open-uri'
		#output = IO.popen(["python", "#{Rails.root}/app/scrapers/weedmaps_disp_scraper.py", @state_name])
		output = nil
		if @city_range.present?
            output = IO.popen(["python", "#{Rails.root}/app/scrapers/weedmaps_disp_scraper.py", @state_name, '-city='+ @city_range])
		else
            output = IO.popen(["python", "#{Rails.root}/app/scrapers/weedmaps_disp_scraper.py", @state_name])
		end
		contents = JSON.parse(output.read)
		#logger.info 'first contents: '
		#logger.info contents['washington'][0]
		#contents.clear
		
		#LOOP THROUGH CONTENTS RETURNED (DISPENSARIES)
		contents['washington'].each do |returned_dispensary_source|
			
			#check if the dispensary source already exists
			existing_dispensary_sources = @dispensary_sources.select { |dispensary_source| dispensary_source.name.casecmp(returned_dispensary_source['name']) == 0 }
			
			if existing_dispensary_sources.size > 0 #DISPENSARY SOURCE ALREADY EXISTS
				
				#loop through products and see if we need to create any or update any
				if returned_dispensary_source['menu'] != nil 
					checkProductsStillExist(returned_dispensary_source['menu'], existing_dispensary_sources[0], false)
				end
			end #end of existing dispensary source if statement
				
		end #end of contents loop 
	
	end #end of main scraper method

	
	
	#BEGIN HELPER METHODS
	
	
	
	#method to loop through the dispensary products (items) and determine the correct course of action 
	def checkProductsStillExist(returned_json_menu, existing_dispensary_source, is_new_dispensary)


		#loop through existing dispensary 
		existing_dispensary_source.products.each do |existing_product|

			still_exists = false
			not_found = false

			while still_exists = false

				#loop through returned menu to see if product still exists
				returned_json_menu.each_with_index do |returned_menu_section, index|

					#right now we are only doing flowers
					if ['Indica', 'Hybrid', 'Sativa', 'Flower'].include? returned_menu_section['title']
						returned_menu_section['items'].each do |returned_dispensary_source_product|

							if returned_dispensary_source_product['name'].casecmp(existing_product.name)
								still_exists = true
								break
							else
								#loop through alternate names and check
								if existing_product.alternate_names.present? 
									existing_product.alternate_names.split(',').each do |alt|
										if alt.casecmp(returned_dispensary_source_product['name']) == 0
											still_exists = true
											break
										end
									end
								end

								if still_exists == false

									#check products with vendor name
									if existing_product.vendors.any?
										existing_product.vendors.each do |vendor|
											combined = []
											combined.push("#{existing_product.name} - #{vendor.name}")
											combined.push("#{vendor.name} - #{existing_product.name}")
											combined.push("#{existing_product.name} by #{vendor.name}")
											combined.push("#{existing_product.name} : #{vendor.name}")
											combined.push("#{vendor.name} : #{existing_product.name}")
											combined.push("#{existing_product.name} (#{vendor.name})")
											combined.push("#{existing_product.name} by #{vendor.name} of Washington")

											product_vendor_matches = combined.select { |product_vendor| 
														product_vendor.casecmp(returned_dispensary_source_product['name']) == 0 }

											if product_vendor_matches.size > 0
												still_exists = true
												break
											end
										end
									end
								end

							end

						end #end loop through category items
					end #end if statement to confirm its a flower

					#see if im out of returned menu sections and still_exists = false
					if index == returned_json_menu.length - 1
						still_exists = true #just to get out of the while loop
						not_found = true
					end

				end #end loop through returned menu

			end #end of while loop

			if not_found
				#delete dispensary soure product
				existing_product.destroy
			end

			
		end #end loop through existing products
	
	end #end checkProductsStillExist method
	
end