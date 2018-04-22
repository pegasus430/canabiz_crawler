ActiveAdmin.register Category do

	menu :if => proc{ current_admin_user.admin? }
	
	permit_params :name, :keywords, :active, :category_type
	
	#use with friendly id
    before_filter :only => [:show, :edit, :update, :delete] do
    	@category = Category.friendly.find(params[:id])
    end
	
	scope :all, default: true
	scope :news
	scope :products
	scope :active
	
	index do
		column :name
		column :keywords
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
