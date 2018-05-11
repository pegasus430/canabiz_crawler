ActiveAdmin.register Category do

	menu :if => proc{ current_admin_user.admin? }
	
	permit_params :name, :keywords, :active, :category_type
	
	#use with friendly id
    before_filter :only => [:show, :edit, :update, :delete] do
    	@category = Category.friendly.find(params[:id])
    end
    
    #-----CSV ACTIONS ----------#
    
    #import csv
	action_item only: :index do
		if current_admin_user.admin?
			link_to 'Import Categories', admin_categories_import_categories_path, class: 'import_csv'
		end
	end
	
	#export csv
	csv do
		column :name
		column :keywords
		column :active
		column :category_type
	end
	
	collection_action :import_categories do
		if request.method == "POST"
			if params[:category][:file_name].present?
				file_data = params[:category][:file_name]
				if file_data.respond_to?(:read)
					categories = file_data.read
					Category.import_from_csv(categories)
					flash[:notice] = "Categories imported successfully."
				elsif file_data.respond_to?(:path)
					categories = File.read(file_data.path)
					Category.import_from_csv(categories)
					flash[:notice] = "Categories imported successfully."
				end
			end
			redirect_to admin_categories_path
		end
	end	
	
	#-----CSV ACTIONS ----------#
	
	scope :all, default: true
	scope :news
	scope :products
	scope :active
	
	index do
		selectable_column
		column :name
		column "Keywords" do |category|
          truncate(category.keywords, omision: "...", length: 100) if category.keywords
        end
		column :active
		column :category_type
		column :created_at
		column :updated_at
		actions
	end
	
	form(:html => { :multipart => true }) do |f|
		f.inputs do
			f.input :name
			f.input :keywords
			f.input :active
			f.input :category_type
		end
		f.actions
	end

end
