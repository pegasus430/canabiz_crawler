ActiveAdmin.register DispensarySourceOrder do

	menu priority: 4, label: 'Dispensary Orders'
	
	permit_params :shipped, :picked_up
	
	index do
		
		if current_admin_user.admin?
			column :id
			column "Dispensary Source" do |dso|
				if dso.dispensary_source.present?
					link_to "#{dso.dispensary_source.name} - #{dso.dispensary_source.source.name}", admin_dispensary_source_path(dso.dispensary_source)
				end
			end
			column "Order" do |dso|
				if dso.order.present?
					link_to dso.order.name , admin_order_path(dso.order)
				end
			end
		end
		column :shipped, label: 'Delivered'
		column :picked_up
		column :created_at
		column :updated_at
		actions
	end
    
	show do |dispensary_order|
	  
		if current_admin_user.admin?
			#show dispensary information
			#if not admin they only see their orders
		end
		
		panel 'Customer Details' do
			if dispensary_order.order.present?
				attributes_table_for dispensary_order.order, :name, :email, :phone, :address, :city, :country
			end
		end
		
		panel 'Order Details' do
			table_for(dispensary_order) do
				column 'Created At' do |dso|
					"#{time_ago_in_words dispensary_order.created_at} ago"
				end
				column 'Delivered' do |dso|
					dso.shipped
				end
				column 'Picked Up' do |dso|
					dso.picked_up
				end
			end
		end
		
		panel 'Products' do
			table_for(dispensary_order.product_items) do
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
			number_to_currency dispensary_order.total_price
		end
	  
	end
	
end
