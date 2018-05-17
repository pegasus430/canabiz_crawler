ActiveAdmin.register ProductState do

    menu :if => proc{ current_admin_user.admin? }
	
	permit_params :product_id, :state_id
	
	#save queries
	includes :product, :state
	
	index do
		selectable_column
		column "Product" do |ps|
			if ps.product.present?
				link_to ps.product.name, admin_product_path(ps.product)
			end
		end
		column "State" do |ps|
			if ps.state.present?
				link_to ps.state.name, admin_vendor_path(ps.state)
			end
		end
		column :created_at
		column :updated_at
		actions
	end

	form do |f|
		f.input :product_id, :label => 'Product', :as => :select, 
				:collection => Product.order('name ASC').map{|u| ["#{u.name}", u.id]}
		f.input :state_id, :label => 'State', :as => :select, 
				:collection => State.order('name ASC').map{|u| ["#{u.name}", u.id]}
    	f.actions
    end

end
