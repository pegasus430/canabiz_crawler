ActiveAdmin.register DspPrice do
    
    menu :if => proc{ current_admin_user.admin? }
	
	permit_params :dispensary_source_product_id, :price, :unit, :display_order
	
	#save queries
	includes :dispensary_source_product => :product
	
	index do
		selectable_column
		column "Product" do |dsp|
			if dsp.dispensary_source_product.present?
				link_to dsp.dispensary_source_product.product.name, admin_product_path(dsp.dispensary_source_product.product)
			end
		end
		column "Dispensary Source Product" do |dsp|
			if dsp.dispensary_source_product.present?
				link_to dsp.dispensary_source_product.id, admin_dispensary_products_path(dsp.dispensary_source_product)
			end
		end
		column :price
		column :unit
		column :display_order
		column :created_at
		column :updated_at
		actions
	end

	form do |f|
		panel " " do	
			f.input :dispensary_source_product_id, :label => 'Dispensary Source Product', :as => :select, 
					:collection => DispensarySourceProduct.all.map{|u| ["#{u.id}", u.id]}
		end
		panel " " do	 		
			f.input :price
		end 	
		panel " " do	
			f.input :unit
		end 
		panel " " do		
			f.input :display_order
		end 	
	    	f.actions
	    end

end
