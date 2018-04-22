ActiveAdmin.register VendorProduct do

	#NEEDS TO BE ALTERED!

	menu :if => proc{ current_admin_user.admin? }
	
	permit_params :product_id, :average_price, :average_price_unit, :units_sold, :display_order
	
	#save queries
	includes :product
	
	index do
		column :product_id
		column :average_price
		column :average_price_unit
		column :units_sold
		column :display_order
	end

	form do |f|
		f.input :product_id, :label => 'Product', :as => :select, 
				:collection => Product.all.map{|u| ["#{u.name}", u.id]}
		f.input :average_price
		f.input :average_price_unit
		f.input :units_sold
		f.input :display_order
    	f.actions
    end

end
