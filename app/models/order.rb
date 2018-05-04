class Order < ActiveRecord::Base
	has_many :product_items, dependent: :destroy
	validates :name, :email, :phone, :address, :city, presence: true
	
	#belongs_to :dispensary_source
	#belongs_to :dispensary
	
	def add_product_items_from_cart(cart)
		cart.product_items.each do |item|
			item.cart_id = nil
			product_items << item
		end
	end
	
	def total_price
		product_items.map(&:total_price).sum	
	end
	
	#after_validation :create_dispensary_source_orders, on: [ :create ]
	def create_dispensary_source_orders(order)
		
		puts 'STEVE IS HERE'
		
		dispensarySourceIds = Set.new 
		order.product_items.each do |product_item|
			puts 'STEVE IS HERE'
			puts product_item.dispensary_source.name
			dispensarySourceIds.add(product_item.dispensary_source_id)
		end
		
		dispensary_source_orders = Array.new
		
		dispensarySourceIds.each do |setObject|
			puts 'STEVE IS HERE'
			puts setObject
            dso = DispensarySourceOrder.create(:dispensary_source_id => setObject, :order_id => order.id)
            # dso.add_product_items_from_order(self)
            dispensary_source_orders.push(dso)
        end
		
		order.product_items.each do |product_item|
			
			puts 'STEVE IS in second loop'
			
			dispensary_source_orders.each do |dso|
				puts 'STEVE IS in second loop 2'
				if dso.dispensary_source_id == product_item.dispensary_source_id
					puts 'STEVE IS in second loop 3 '
					product_item.update_attribute :dispensary_source_order_id, dso.id
				end
			end
		end 
	end
end
