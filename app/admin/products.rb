ActiveAdmin.register Product do
  permit_params :name, :image, :ancillary, :product_type, :slug, :description, :featured_product, 
    :short_description, :category_id, :year, :month, :alternate_names, :sub_category, :is_dom, :cbd, 
    :cbn, :min_thc, :med_thc, :max_thc, :dsp_count, :headset_alltime_count, :headset_monthly_count,
    :headset_weekly_count, :headset_daily_count
  
  menu priority: 6, :if => proc{ current_admin_user.admin? }
  
  #use with friendly id
  before_filter :only => [:show, :edit, :update, :delete] do
    @product = Product.friendly.find(params[:id])
  end
  
  #actions :index, :show, :new, :create, :update, :edit
  
  #scopes
  scope :all, default: true
  scope :featured
  
  #save queries
  includes :category, :vendor, :vendors, :dispensary_source_products, :dispensary_sources
  
  #filters
  filter :name
    filter :featured_product
    filter :state_id
    filter :category_id
    filter :sub_category
  
  #-----CSV ACTIONS ----------#
    
    #import csv
  action_item only: :index do
    if current_admin_user.admin?
      link_to 'Import Products', admin_products_import_products_path, class: 'import_csv'
    end
  end
  
  #export csv
  csv do
    column :name
    column :image
    column :description
    column :featured_product
    column :alternate_names
    column :category_id
    column :sub_category
    column :is_dom
    column :cbd
    column :cbn
    column :min_thc
    column :med_thc
    column :max_thc
    column :headset_alltime_count
    column :headset_monthly_count
    column :headset_weekly_count 
    column :headset_daily_count
  end
  
  collection_action :import_products do
    if request.method == "POST"
      if params[:product][:file_name].present?
        file_data = params[:product][:file_name]
        if file_data.respond_to?(:read)
          products = file_data.read
          Product.import_from_csv(products)
          flash[:notice] = "Products imported successfully."
        elsif file_data.respond_to?(:path)
          products = File.read(file_data.path)
          Product.import_from_csv(products)
          flash[:notice] = "Products imported successfully."
        end
      end
      redirect_to admin_products_path
    end
  end 
  
  #-----CSV ACTIONS ----------#

  index do
    selectable_column
    id_column
    column :name
    column :alternate_names
    column "Description" do |product|
          truncate(product.description, omision: "...", length: 50)
        end
    column "Image" do |product|
      if product.image.present?
        image_tag product.image_url, class: 'admin_image_size'
      end
    end
    column :featured_product
    column "Category" do |product|
      if product.category.present?
        link_to product.category.name, admin_category_path(product.category)
      end
    end
    column "Vendor" do |product|
      vendors = product.vendors
      unless vendors.blank?
        vendors.each.map do |vendor|
          link_to(vendor.name, admin_vendor_path(vendor)) 
        end.join(', ').html_safe
      end
    end
    column :sub_category
    column :updated_at
    column :headset_alltime_count
    column :headset_monthly_count
    column :headset_weekly_count 
    column :headset_daily_count
    column "DispensaryProduct" do |product|
      dsps = product.dispensary_source_products
      unless dsps.blank?
        dsps.each.map do |dsp|
          link_to(dsp.dispensary_source.name, admin_dispensary_product_path(dsp)) 
        end.join(', ').html_safe
      end
    end
    actions
  end
  
    #edit and new form - multipart allows for carrierwave connection
  form(:html => { :multipart => true }) do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Product" do
      f.input :name
      f.input :alternate_names
      f.input :description
      f.input :image, :as => :file
      f.input :featured_product
      
      f.input :category_id, :label => 'Category', :as => :select, 
            :collection => Category.products.map{|u| ["#{u.name}", u.id]}
            
      f.input :sub_category
      f.input :is_dom
      f.input :cbd
      f.input :cbn
      f.input :min_thc
      f.input :med_thc
      f.input :max_thc
    end
    f.actions
  end
end