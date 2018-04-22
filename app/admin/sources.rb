ActiveAdmin.register Source do

	menu :if => proc{ current_admin_user.admin? }
	
	permit_params :name, :url, :active, :source_type
	
	#use with friendly id
    before_filter :only => [:show, :edit, :update, :delete] do
    	@source = Source.friendly.find(params[:id])
    end
	
	index do
		column :name
		column :url
		column :active
		column :source_type
		column :created_at
		column :updated_at
		actions
	end
	
	form(:html => { :multipart => true }) do |f|
		f.inputs do
			f.input :name
			f.input :url
			f.input :active
			f.input :source_type
		end
		f.actions
	end

end
