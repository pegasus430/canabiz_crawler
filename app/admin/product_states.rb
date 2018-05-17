ActiveAdmin.register ProductState do

    menu :if => proc{ current_admin_user.admin? }
	
	permit_params :product_id, :state_id
	
	#save queries
	includes :product, :state
	
	index do
		column "Product" do |vp|
			if vp.product.present?
				link_to vp.product.name, admin_product_path(vp.product)
			end
		end
		column "State" do |vp|
			if vp.state.present?
				link_to vp.state.name, admin_vendor_path(vp.state)
			end
		end
		column :created_at
		column :updated_at
	end

	form do |f|
		f.input :product_id, :label => 'Product', :as => :select, 
				:collection => Product.order('name ASC').map{|u| ["#{u.name}", u.id]}
		f.input :state_id, :label => 'State', :as => :select, 
				:collection => State.order('name ASC').map{|u| ["#{u.name}", u.id]}
    	f.actions
    end

end
