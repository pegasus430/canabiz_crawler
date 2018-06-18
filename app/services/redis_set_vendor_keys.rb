class RedisSetVendorKeys
	
	#use this to set vendor product keys
	def initialize()
	end
	
	def set_vendor_keys()
		
		puts 'the vendor service is running'
	   
		Vendor.all.each do |vendor|
			vendor_products = vendor.products.featured.includes(:average_prices, :vendors, :category)
        	$redis.set("#{vendor.name.downcase}_products", Marshal.dump(vendor_products)) 	
		end
		
	end
end