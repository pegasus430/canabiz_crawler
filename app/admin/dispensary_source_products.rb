ActiveAdmin.register DispensarySourceProduct, as: "Dispensary Products" do
	
	menu priority: 5
	
	permit_params :dispensary_source_id, :product_id
	
	#save queries
	includes :dispensary_source, :product
	
	index do
		column :dispensary_source_id
		column :product_id
		column :created_at
		column :updated_at
	end

	form do |f|
		f.input :dispensary_source_id, :label => 'Dispensary Source', :as => :select, 
				:collection => DispensarySource.all.map{|u| ["#{u.name}", u.id]}
		f.input :product_id, :label => 'Product', :as => :select, 
				:collection => Product.all.map{|u| ["#{u.name}", u.id]}
    	f.actions
    end

end