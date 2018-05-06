ActiveAdmin.register VendorProduct do

	#NEEDS TO BE ALTERED!

	menu :if => proc{ current_admin_user.admin? }
	
	permit_params :product_id, :vendor_id, :units_sold
	
	#save queries
	includes :product, :vendor
	
	index do
		column "Product" do |vp|
			if vp.product.present?
				link_to vp.product.name, admin_product_path(vp.product)
			end
		end
		column "Vendor" do |vp|
			if vp.vendor.present?
				link_to vp.vendor.name, admin_vendor_path(vp.vendor)
			end
		end
		column :units_sold
		column :created_at
		column :updated_at
	end

	form do |f|
		f.input :product_id, :label => 'Product', :as => :select, 
				:collection => Product.order('name ASC').map{|u| ["#{u.name}", u.id]}
		f.input :vendor_id, :label => 'Vendor', :as => :select, 
				:collection => Product.order('name ASC').map{|u| ["#{u.name}", u.id]}
		f.input :units_sold
    	f.actions
    end

end
