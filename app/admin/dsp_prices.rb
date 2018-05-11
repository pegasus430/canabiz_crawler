ActiveAdmin.register DspPrice do
    
    menu :if => proc{ current_admin_user.admin? }
	
	permit_params :dispensary_source_product_id, :price, :unit, :display_order
	
	#save queries
	includes :dispensary_source_product
	
	index do
		column :dispensary_source_product_id
		column :price
		column :unit
		column :display_order
	end

	form do |f|
		f.input :dispensary_source_product_id, :label => 'Dispensary Source Product', :as => :select, 
				:collection => DispensarySourceProduct.all.map{|u| ["#{u.name}", u.id]}
		f.input :price
		f.input :unit
		f.input :display_order
    	f.actions
    end

end
