class ProductHelper

	def initialize(products, ip_address)
		@products = products
		@ip_address = ip_address
	end
	
	def findProductsPriceAndDistance()
		
		#hash returned
		@product_to_distance = Hash.new
		@product_to_closest_disp = Hash.new
		
		@products.each do |product|
			
			#distance
			if @ip_address != nil
				closest_distance = nil
				closest_dispensary = nil
				
				product.dispensary_sources.each do |dispSource|
					
					if closest_distance == nil || dispSource.distance_to(@ip_address) < closest_distance
						closest_distance = dispSource.distance_to(@ip_address).round(2)	
						closest_dispensary = dispSource.dispensary
					end
				end
				
				@product_to_distance.store(product, closest_distance)
				@product_to_closest_disp.store(product, closest_dispensary)
			end
		end
		
		#return
		[@product_to_distance, @product_to_closest_disp]
	end
end