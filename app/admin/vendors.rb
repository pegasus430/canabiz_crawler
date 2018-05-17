ActiveAdmin.register Vendor do
	menu :if => proc{ current_admin_user.admin? }
	
	permit_params :name, :description, :image, :tier, :vendor_type, 
	                :address, :total_sales, :license_number, :ubi_number, :dba, :month_inc, 
	                :year_inc, :month_inc_num
	
	index do
		column :name
		column "Description" do |vendor|
			truncate(vendor.description, omision: "...", length: 50) if vendor.description
        end
        column "Image" do |vendor|
			truncate(vendor.image_url, omision: "...", length: 50) if vendor.image_url
        end
		column :created_at
		column :updated_at
		actions
	end
end