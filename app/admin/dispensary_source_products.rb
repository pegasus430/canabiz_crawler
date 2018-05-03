ActiveAdmin.register DispensarySourceProduct, as: "Dispensary Products" do
	
	menu priority: 5
	
	permit_params :dispensary_source_id, :product_id
	
	#save queries
	includes :dispensary_source, :product
	
	index do
		column "Dispensary Source" do |dsp|
			if dsp.dispensary_source.present?
				link_to "#{dsp.dispensary_source.name} - #{dsp.dispensary_source.source.name}", admin_dispensary_source_path(dsp.dispensary_source)
			end
		end
		column "Product" do |dsp|
			if dsp.product.present?
				link_to dsp.product.name , admin_product_path(dsp.product)
			end
		end
		column :created_at
		column :updated_at
	end

	form do |f|
		f.input :dispensary_source_id, :label => 'Dispensary Source', :as => :select, 
				:collection => DispensarySource.order('name ASC').map{|u| ["#{u.name}", u.id]}
		f.input :product_id, :label => 'Product', :as => :select, 
				:collection => Product.order('name ASC').map{|u| ["#{u.name}", u.id]}
    	f.actions
    end

end