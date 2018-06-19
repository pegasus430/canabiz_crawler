class RedisSetDispensaryKeys
	
	def initialize()
	end
	
	def set_dispensary_keys()
		
		puts 'the dispensary service is running'
		
		Dispensary.each do |dispensary|
			@dispensary_source = dispensary.dispensary_sources.order('last_menu_update DESC').first
	        @dispensary_source_products = @dispensary_source.dispensary_source_products.
	                    includes(:dsp_prices, product: [:category, :vendors, :vendor])
	        
	        @category_to_products = Hash.new
	        
	        @dispensary_source_products.each do |dsp|
	            
	            if dsp.product.present? && dsp.product.featured_product && dsp.product.category.present?
	                if @category_to_products.has_key?(dsp.product.category.name)
	                    @category_to_products[dsp.product.category.name].push(dsp)
	                else
	                    @category_to_products.store(dsp.product.category.name, [dsp])
	                end
	            end
	        end	
	        $redis.set("#{dispensary.name.downcase}_dispensary_source", Marshal.dump(@dispensary_source))
	        $redis.set("#{dispensary.name.downcase}_category_to_products", Marshal.dump(@category_to_products))
		end
	end
end