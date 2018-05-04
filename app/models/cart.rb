class Cart < ActiveRecord::Base
	
	has_many :product_items, dependent: :destroy
	
	def add_product(product_id, dispensary_source_id, dsp_price_id, quantity)
		#current_item = product_items.find_by(product_id: product_id)
		#see if this item is currently in this cart
		current_items = product_items.where(product_id: product_id).
							where(dispensary_source_id: dispensary_source_id).where(dsp_price_id: dsp_price_id)
							
		current_item = nil
		if current_items.size > 0
			current_item = current_items[0]
			current_item.quantity += quantity
		else
			current_item = product_items.build(product_id: product_id, 
								dispensary_source_id: dispensary_source_id, dsp_price_id: dsp_price_id, quantity: quantity)
		end
		current_item
	end
	
	def total_price
		#to_a = to array
		product_items.to_a.sum{|item| item.total_price}
	end
end
