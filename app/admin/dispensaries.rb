ActiveAdmin.register Dispensary do
    permit_params :name, :admin_user_id
    
    menu priority: 3, label: 'Dispensary Info'
  
    #use with friendly id
    before_filter :only => [:show, :edit, :update, :delete] do
    	@dispensary = Dispensary.friendly.find(params[:id])
    end
    
    #save queries
	includes :state

    index do
        column :name
        column :admin_user_id
        column :state_id
        column :updated_at
        actions
    end

    filter :name
    filter :admin_user_id, :if => proc{ current_admin_user.admin? }
    
    scope :all, default: true, :if => proc{ current_admin_user.admin? }
    scope :has_admin, :if => proc{ current_admin_user.admin? } 
  
    form do |f|
        f.inputs "Dispensary" do
            f.input :name
            
            if current_admin_user.admin?
                f.input :admin_user_id, :label => 'Admin User', :as => :select, 
                :collection => AdminUser.all.map{|u| ["#{u.email}", u.id]}
            end
        end
        f.actions
    end

end
