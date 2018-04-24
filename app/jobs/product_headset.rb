class ProductHeadset < ActiveJob::Base
    include SuckerPunch::Job
 
 	#have to make work for multiple states - state_name would be a string like 'washington nevada'
 	#I have to split into array and populate lists based on array
 	#how to split: https://stackoverflow.com/questions/975769/how-to-split-a-delimited-string-in-ruby-and-convert-it-to-an-array
    def perform(state_name)
        logger.info "Headset background job is running"
        @state_name = state_name
        #@state_record = State.where(name: @state_name).first
        #@categories = Category.products.active
        #@products = Product.where(state_id: @state_record.id)
        #@vendors = Vendor.where(state_id: @state_record.id)
        scrapeHeadset()
    end    
    
    def scrapeHeadset()
        
        require "json"
        require 'open-uri'
        
        begin
	        output = IO.popen(["python", "#{Rails.root}/app/scrapers/scrapers_env_info.py"])
	        contents = JSON.parse(output.read)
	        
	        #call method
			logger.info "here are the results: " 
			logger.info contents

			if @contents[@state_name] != nil
				logger.info "HEADSET DID RETURN PRODUCTS"
				#parseProducts(contents[@state_name])
			else
				logger.info "HEADSET DID NOT RETURN ANY PRODUCTS"
			end
		rescue => ex
			logger.info "THERE WAS A HEADSET ERROR: "
			logger.info ex.message
		end
    end

    def parseProducts(state_products)

    	state_products.each do |category|

    		logger.info 'category: ' 
    		logger.info category

    		#check if the category itself is in the system
			existing_categories = @categories.select { |product_category| product_category.name.casecmp(category) == 0 }

			if existing_categories.size > 0
				product_category = existing_categories[0]

				category['items'].each do |item|

					checkVendorAndProduct(item)
				end
			end
    	end #end of category loop
    end #end of parseProducts method


    #method to check if product and vendor are in system - if not create
    def checkVendorAndProduct(item)
    	
    	#check if the vendor itself is in the system
		existing_vendors = @vendors.select { |vendor| vendor.name.casecmp(item['brand_name']) == 0 }
		vendor = nil
		if existing_vendors.size > 0
			#still need to check if vendor product 
			vendor = existing_vendors[0]
		else
			#vendor not in system - create
			vendor = Vendor.new(
				:title => item["brand_name"], 
				:remote_image_url => item["brand_image"],
				:state_id => @state_record.id
        	)
        	unless vendor.save
        		puts "vendor Save Error: #{vendor.errors.messages}"
        	end
		end

		#check if the product itself is in the system
    	product_name = ''
    	average_price_unit = ''
    	if item['product_name'].index('(') != nil
    		product_name = item['product_name'][0, item['product_name'].index('(') - 1].strip
    		average_price_unit = item['product_name'][item['product_name'].index('(') + 1, 
    								item['product_name'].index(')') - 1].strip
    	else
    		product_name = item['product_name']
    		average_price_unit = 'unit'
    	end

		existing_products = @products.select { |product| product.name.casecmp(product_name) == 0 }
		product = nil
		if existing_products.size > 0
			#still need to check if vendor product 
			product = existing_products[0]
		else
			#product not in system - create
			product = Product.new(
				:title => item["brand_name"], 
				:remote_image_url => item["brand_image"],
				:state_id => @state_record.id
        	)
        	unless product.save
        		puts "product Save Error: #{product.errors.messages}"
        	end
		end

		#check vendor product
		existing_vp = VendorProduct.where(vendor_id: vendor.id).where(product_id: product.id)

		if (existing_vp.size == 0)
			vendor_product = VendorProduct.new(
				:vendor_id => vendor.id, 
				:product_id => product.id
        	)
        	unless vendor_product.save
        		puts "vendor_product Save Error: #{vendor_product.errors.messages}"
        	end
		end

		#check average price - if exists, update price, if not create
		average_price = AveragePrice.where(product_id: product.id).where(average_price_unit: average_price_unit)
		
		price = nil
		if item['product_price'].index('$') != nil
			price = item['product_price'][0, item['product_price'].index('$') - 1].strip
		else 
			price = item['product_price']
		end

		if (average_price.size == 0)
			vendor_product = AveragePrice.new(
				:product_id => vendor.id, 
				:average_price => price,
				:average_price_unit => average_price_unit
        	)
        	unless vendor_product.save
        		puts "vendor_product Save Error: #{vendor_product.errors.messages}"
        	end
		else
			average_price[0].update_attribute :average_price, price
		end


    end #end of checkVendorAndProduct method
end