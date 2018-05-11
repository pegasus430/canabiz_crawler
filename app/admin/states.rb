ActiveAdmin.register State do

	menu :if => proc{ current_admin_user.admin? }
	
	permit_params :name, :abbreviation, :keywords, :logo, :product_state

	#use with friendly id
    before_filter :only => [:show, :edit, :update, :delete] do
    	@state = State.friendly.find(params[:id])
    end
    
    scope :all, default: true, :if => proc{ current_admin_user.admin? }
    scope :product_state, :if => proc{ current_admin_user.admin? }
    
    filter :name
    filter :product_state
	
	index do
		column :name
		column :abbreviation
		column :keywords
		column :logo
		column :product_state
		column :created_at
		column :updated_at
		actions
	end
	
	form(:html => { :multipart => true }) do |f|
		f.inputs do
			f.input :name
			f.input :abbreviation
			f.input :keywords
			f.input :logo
			f.input :product_state
		end
		f.actions
	end

end
