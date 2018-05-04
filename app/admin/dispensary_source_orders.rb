ActiveAdmin.register DispensarySourceOrder do

	menu priority: 4, label: 'Dispensary Orders'
	
	permit_params :shipped, :picked_up
	
	filter :created_at
	filter :updated_at
	filter :shipped, label: 'Delivered'
	filter :picked_up
	
	form(:html => { :multipart => true }) do |f|
		f.inputs do
			# f.input :name, input_html: { disabled: true } --> maybe display some other fields
			f.input :shipped, label: 'Delivered'
			f.input :picked_up
		end
		f.actions
	end
	
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
		
		if current_admin_user.dispensary_admin_user?
			column "Customer" do |dso|
				if dso.order.present?
					dso.order.name
				end
			end
			column "Location" do |dso|
				if dso.order.present?
					dso.order.address + ', ' + dso.order.city
				end
			end
		end
		
		column "Total Price" do |dso|
			'$' + dso.total_price.to_s	
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
