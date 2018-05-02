ActiveAdmin.register DispensarySource do
	
	menu priority: 4, label: 'Dispensary Info'
	
	permit_params :name, :admin_user_id, :state_id, :dispensary_id, :source_id,
					:image, :location, :street, :city, :zip_code, :last_menu_update,
					:facebook, :instagram, :twitter, :website, :email, :phone, :min_age,
					:monday_open_time, :monday_close_time, :tuesday_open_time, :tuesday_close_time,
					:wednesday_open_time, :wednesday_close_time, :thursday_open_time, :thursday_close_time,
					:friday_open_time, :friday_close_time, :saturday_open_time, :saturday_close_time,
					:sunday_open_time, :sunday_close_time
					
	
	scope :all, default: true, :if => proc{ current_admin_user.admin? }
    scope :has_admin, :if => proc{ current_admin_user.admin? }
    
    filter :name
    filter :state_id
    
    #save queries
	includes :dispensary, :source, :state, :admin_user
    
    index do
        column :name
        
        column "Image" do |dispensary|
			if dispensary.image.present?
				image_tag dispensary.image_url, class: 'admin_image_size'
			end
		end
        
        if current_admin_user.admin?
        	
        	column "Dispensary" do |ds|
				if ds.dispensary.present?
					link_to ds.dispensary.name, admin_dispensary_path(ds.dispensary_id)
				end
			end
			column "Source" do |ds|
				if ds.source.present?
					link_to ds.source.name, admin_source_path(ds.source_id)
				end
			end
			column :source_rating
			column "Admin User" do |ds|
			  link_to ds.admin_user.email, admin_admin_user_path(ds.admin_user_id) if ds.admin_user
			end
			column "State" do |ds|
				if ds.state.present?
					link_to ds.state.name, admin_state_path(ds.state_id)
				end
			end
		end
		
		
		column :street
		column :city
		column "State" do |ds|
			if ds.state.present?
				ds.state.name
			end
		end
		column :zip_code
		column :location
		
		if !current_admin_user.admin?
			column	:instagram
			column	:twitter
			column	:website
			column	:email
			column	:phone, label: 'Phone Number'
			column	:min_age, label: 'Minimum Age'
			
			column	:monday_open_time
			column	:tuesday_open_time
			column	:wednesday_open_time
			column	:thursday_open_time
			column	:friday_open_time
			column	:saturday_open_time
			column	:sunday_open_time
			column	:monday_close_time
			column	:tuesday_close_time
			column	:wednesday_close_time
			column	:thursday_close_time
			column	:friday_close_time
			column	:saturday_close_time
			column	:sunday_close_time
		end
		
		column :updated_at
		#should make a new column thats like - awaiting approval - everytime they change it I set it
        actions
    end
    
    form(:html => { :multipart => true }) do |f|
		f.inputs do
			
			if current_admin_user.dispensary_admin_user?
				f.input :name, input_html: { disabled: true } 
			end
			
			if current_admin_user.admin?
				f.input :name
				f.input :admin_user_id, :label => 'Admin User', :as => :select, 
                :collection => AdminUser.order('email ASC').map{|u| ["#{u.email}", u.id]}
				f.input :dispensary_id, :label => 'Dispensary', :as => :select, 
						:collection => Dispensary.order('name ASC').map{|u| ["#{u.name}", u.id]}
				f.input :source_id, :label => 'Source', :as => :select, 
						:collection => Source.where(source_type: ['Dispensary', 'Both']).order('name ASC').
										map{|u| ["#{u.name}", u.id]}
				f.input :state_id, :label => 'State', :as => :select, 
					:collection => State.order('name ASC').map{|u| ["#{u.name}", u.id]}
				f.input :source_rating
				f.input :last_menu_update
			end
			
			f.input :image, :as => :file
			f.input :street
			f.input :city
			f.input :zip_code
			
			f.input :instagram
		    f.input :twitter
		    f.input :website
		    f.input :email
		    f.input :phone, label: 'Phone Number'
		    f.input	:min_age, label: 'Minimum Age'
		    
		    f.input :monday_open_time
			f.input :tuesday_open_time
			f.input :wednesday_open_time
			f.input :thursday_open_time
			f.input :friday_open_time
			f.input :saturday_open_time
			f.input :sunday_open_time
			f.input :monday_close_time
			f.input :tuesday_close_time
			f.input :wednesday_close_time
			f.input :thursday_close_time
			f.input :friday_close_time
			f.input :saturday_close_time
			f.input :sunday_close_time
		end
		f.actions
  end
	
	
end
