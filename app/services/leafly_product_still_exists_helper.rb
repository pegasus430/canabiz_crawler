class LeaflyProductStillExistsHelper

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
								includes(:products => :vendors, :dispensary_source_products)


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
				
				#compare our products with the ones returned
				if returned_dispensary_source['menu'] != nil
					checkIfProductsExist(returned_dispensary_source['menu'], existing_dispensary_sources[0], false)
				end
				
			end #end of if statement seeing if dispensary source exists or not
				
		end #end of contents loop 

	end #end of main scraper method
	
	
	#BEGIN HELPER METHODS
	
	
	#method to see if our products still exist
	def checkIfProductsExist(returned_json_menu, existing_dispensary_source, is_new_dispensary)

		valid_menu_sections = []
		valid_menu_sections.push(returned_json_menu['Flower'])


		#loop through existing_dispensary_source products
		existing_dispensary_source.products.each do |existing_product|

			


		end #end existing_dispensary_source product loop

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

	end #checkIfProductsExist 
	
end #end of class