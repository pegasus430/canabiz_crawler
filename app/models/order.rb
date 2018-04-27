class Order < ActiveRecord::Base
	has_many :product_items, dependent: :destroy
	validates :name, :email, :phone, :address, :city, :state, presence: true
	
	def add_product_items_from_cart(cart)
		cart.product_items.each do |item|
			item.cart_id = nil
			product_items << item
		end
	end
	
	def total_price
		product_items.map(&:total_price).sum	
	end
end
