ActiveAdmin.register VendorState do

    menu :if => proc{ current_admin_user.admin? }
	
	permit_params :vendor_id, :state_id
	
	#save queries
	includes :vendor, :state
	
	index do
		selectable_column
		column "Vendor" do |vp|
			if vp.vendor.present?
				link_to vp.vendor.name, admin_product_path(vp.vendor)
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
		f.input :vendor_id, :label => 'Vendor', :as => :select, 
				:collection => Vendor.order('name ASC').map{|u| ["#{u.name}", u.id]}
		f.input :state_id, :label => 'State', :as => :select, 
				:collection => State.order('name ASC').map{|u| ["#{u.name}", u.id]}
    	f.actions
    end

end