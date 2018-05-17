ActiveAdmin.register Blog do
    menu :if => proc{ current_admin_user.admin? }, :label => 'Blog'
	
	permit_params :title, :body
	
	#use with friendly id
    before_filter :only => [:show, :edit, :update, :delete] do
    	@blog = Blog.friendly.find(params[:id])
    end
    
    index do
		selectable_column
		column "Title" do |blog|
          truncate(blog.title, omision: "...", length: 50) if blog.title
        end
        column "Body" do |blog|
          truncate(blog.body, omision: "...", length: 150) if blog.body
        end
		column :created_at
		column :updated_at
		actions
	end
	
	form(:html => { :multipart => true }) do |f|
		f.inputs do
			f.input :title
			f.input :body, :input_html => {:rows => 5, :cols => 50}
		end
		f.actions
	end

end
