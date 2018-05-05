ActiveAdmin.register Order do

	show do |order|

		panel 'Customer Details' do
			attributes_table_for order, :name, :email, :phone, :street, :city, :zip_code
		end
		
		panel 'Created' do
			"#{time_ago_in_words order.created_at} ago"
		end
		
		panel 'Order Details' do
			table_for(order.product_items) do
				column 'Product' do |item|
					item.product.name
				end
				column 'Quantity' do |item|
					item.quantity
				end
				column 'Unit' do |item|
					item.dsp_price.unit
				end
				column 'Unit Price' do |item|
					item.dsp_price.price
				end
				column 'Total Price' do |item|
					number_to_currency item.total_price
				end
			end
		end
		
		panel 'Order Total' do 
			number_to_currency order.total_price
		end
	  
	end

end
