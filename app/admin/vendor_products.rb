ActiveAdmin.register VendorProduct do

	menu :if => proc{ current_admin_user.admin? }
	
	permit_params :product_id, :vendor_id, :units_sold
	
	#save queries
	includes :product, :vendor
	
	#filters
    filter :"product_id" , :as => :select, :collection => Product.all.map{|u| [u.name , u.id]}
    filter :"vendor_id" , :as => :select, :collection => Vendor.all.map{|u| [u.name , u.id]}
	
	index do
		selectable_column
		column "Product", :sortable=>:"products.name" do |vp|
			if vp.product.present?
				link_to vp.product.name, admin_product_path(vp.product)
			end
		end
		column "Vendor", :sortable=>:"vendors.name" do |vp|
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
				:collection => Vendor.order('name ASC').map{|u| ["#{u.name}", u.id]}
		f.input :units_sold
    	f.actions
    end

end
