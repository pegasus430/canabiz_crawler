ActiveAdmin.register Product do
	permit_params :name, :image, :ancillary, :product_type, :slug, :description, :featured_product, 
	  :short_description, :category_id, :year, :month, :alternate_names, :sub_category, :is_dom, :cbd, 
	  :cbn, :min_thc, :med_thc, :max_thc, :dsp_count
  
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
	includes :category, :state
	
	#filters
	filter :name
    filter :featured_product
    filter :state_id
    filter :category_id
    filter :sub_category
	
	#-----CSV ACTIONS ----------#
    
    #import csv
	# action_item only: :index do
	# 	if current_admin_user.admin?
	# 		link_to 'Import Products', admin_products_import_products_path, class: 'import_csv'
	# 	end
	# end
	
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
	end
	
	collection_action :import_dispensaries do
		if request.method == "POST"
			if params[:dispensary][:file_name].present?
				file_data = params[:dispensary][:file_name]
				if file_data.respond_to?(:read)
					dispensaries = file_data.read
					Dispensary.import_from_csv(dispensaries)
					flash[:notice] = "Dispensaries imported successfully."
				elsif file_data.respond_to?(:path)
					dispensaries = File.read(file_data.path)
					Dispensary.import_from_csv(dispensaries)
					flash[:notice] = "Dispensaries imported successfully."
				end
			end
			redirect_to admin_dispensaries_path
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
		column "State" do |product|
			if product.state.present?
				link_to product.state.name, admin_category_path(product.state)
			end
		end
		column :sub_category
		column :updated_at
		actions
	end
	
	# index as: :grid do |product|
	#   link_to image_tag(product.image), admin_product_path(product)
	# end
  
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