ActiveAdmin.register ProductState do

    menu :if => proc{ current_admin_user.admin? }
	
	permit_params :product_id, :state_id
	
	#save queries
	includes :product, :state
	
	filter :"state_id" , :as => :select, :collection => State.all.map{|u| [u.name , u.id]}
	filter :"product_id" , :as => :select, :collection => Product.all.map{|u| [u.name , u.id]}
	
	index do
		selectable_column
		column "Product", :sortable=>:"products.name" do |ps|
			if ps.product.present?
				link_to ps.product.name, admin_product_path(ps.product)
			end
		end
		column "State", :sortable=>:"states.name" do |ps|
			if ps.state.present?
				link_to ps.state.name, admin_vendor_path(ps.state)
			end
		end
		column :headset_alltime_count
	    column :headset_monthly_count
	    column :headset_weekly_count 
	    column :headset_daily_count
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
