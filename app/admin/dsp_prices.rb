ActiveAdmin.register DspPrice do
    
    menu :if => proc{ current_admin_user.admin? }
	
	permit_params :dispensary_source_product_id, :price, :unit, :display_order
	
	#scopes
	scope :all, default: true
	scope :for_featured
	
	#save queries
	includes :dispensary_source_product => [:dispensary_source, :product => :category]
	
	index do
		selectable_column
		id_column
		column "Dispensary Source", :sortable=>:"dispensary_sources.name" do |dsp|
			if dsp.dispensary_source_product.present? && dsp.dispensary_source_product.dispensary_source.present?
				link_to dsp.dispensary_source_product.dispensary_source.name, admin_dispensary_source_path(dsp.dispensary_source_product.dispensary_source)
			end
		end
		column "Product", :sortable=>:"products.name" do |dsp|
			if dsp.dispensary_source_product.present? && dsp.dispensary_source_product.product.present?
				link_to dsp.dispensary_source_product.product.name, admin_product_path(dsp.dispensary_source_product.product)
			end
		end
		column "Product Category" do |dsp|
			if dsp.dispensary_source_product.present? && 
				dsp.dispensary_source_product.product.present? && 
					dsp.dispensary_source_product.product.category.present?

	        	link_to dsp.dispensary_source_product.product.category.name , 
	        		admin_category_path(dsp.dispensary_source_product.product.category)
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

	# def scoped_collection
  #    DspPrice.includes(dispensary_source_product: :dispensary_source)
  #  end

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
	    	f.actions
	    end

end