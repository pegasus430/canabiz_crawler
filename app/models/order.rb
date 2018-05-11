class Order < ActiveRecord::Base
	has_many :product_items, dependent: :destroy
	validates :name, :email, :phone, :address, :city, presence: true
	
	def add_product_items_from_cart(cart)
		cart.product_items.each do |item|
			item.cart_id = nil
			product_items << item
		end
	end
	
	def total_price
		product_items.map(&:total_price).sum	
	end
	
	def address
		"#{street}, #{city} #{zip_code}"
	end
	
	#after_validation :create_dispensary_source_orders, on: [ :create ]
	def create_dispensary_source_orders(order)
		
		dispensarySourceIds = Set.new 
		order.product_items.each do |product_item|
			dispensarySourceIds.add(product_item.dispensary_source_id)
		end
		
		dispensary_source_orders = Array.new
		
		dispensarySourceIds.each do |setObject|
			puts setObject
            dso = DispensarySourceOrder.create(:dispensary_source_id => setObject, :order_id => order.id)
            dispensary_source_orders.push(dso)
        end
		
		order.product_items.each do |product_item|
			dispensary_source_orders.each do |dso|
				if dso.dispensary_source_id == product_item.dispensary_source_id
					product_item.update_attribute :dispensary_source_order_id, dso.id
				end
			end
		end 
	end
end
