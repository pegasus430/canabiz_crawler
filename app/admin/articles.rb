ActiveAdmin.register Article do

	menu :if => proc{ current_admin_user.admin? }
	
	permit_params :title, :image, :body, :date, :web_url, :source_id
	
	#use with friendly id
    before_filter :only => [:show, :edit, :update, :delete] do
    	@article = Article.friendly.find(params[:id])
    end
    
    #save queries
	includes :category, :source
	
	index do
		column :title
		column :image
		column :body
		column :created_at
		column :web_url
		column :source_id
		actions
	end
	
	filter :title
	filter :image
	filter :body
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
