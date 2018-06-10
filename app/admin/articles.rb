ActiveAdmin.register Article do

	menu :if => proc{ current_admin_user.admin? }
	
	permit_params :title, :image, :body, :date, :web_url, :source_id
	
	#use with friendly id
    before_filter :only => [:show, :edit, :update, :delete] do
    	@article = Article.friendly.find(params[:id])
    end
    
    #-----CSV ACTIONS ----------#
    
    #import csv
	action_item only: :index do
		if current_admin_user.admin?
			link_to 'Import Articles', admin_articles_import_articles_path, class: 'import_csv'
		end
	end
	
	#export csv
	csv do
		column :title
		column :image
		column :body
		column :created_at
		column :web_url
		column :source_id
	end
	
	collection_action :import_articles do
		if request.method == "POST"
			if params[:article][:file_name].present?
				file_data = params[:article][:file_name]
				if file_data.respond_to?(:read)
					articles = file_data.read
					Article.import_from_csv(articles)
					flash[:notice] = "Articles imported successfully."
				elsif file_data.respond_to?(:path)
					articles = File.read(file_data.path)
					Article.import_from_csv(articles)
					flash[:notice] = "Articles imported successfully."
				end
			end
			redirect_to admin_articles_path
		end
	end
  
	#-----CSV ACTIONS ----------#
  
  
    
    #save queries
	includes :categories, :source
	
	index do
		selectable_column
		id_column
		column "Title", :sortable=>:"articles.title" do |article|
          truncate(article.title, omision: "...", length: 50) if article.title
        end
        column "Image",  :sortable=>:"articles.image"  do |article|
          truncate(article.image_url, omision: "...", length: 50) if article.image
        end
        column "Body",  :sortable=>:"articles.body"   do |article|
          truncate(article.body, omision: "...", length: 50) if article.body
        end
        column "Source",  :sortable=>:"sources.name" do |article|
			if article.source.present?
				link_to article.source.name, admin_source_path(article.source)
			end
		end
		column :web_url
		column :created_at
		actions
	end
	
	filter :title
	filter :image
	filter :body
	filter :source_id
	filter :created_at
	
	form(:html => { :multipart => true }) do |f|
		f.inputs do
			f.input :title
			f.input :image, :as => :file
			f.input :body
			f.input :web_url
			f.input :source_id, :label => 'Source', :as => :select, 
					:collection => Source.all.map{|u| ["#{u.name}", u.id]}
		end
		f.actions
	end

end