ActiveAdmin.register Dispensary do
    permit_params :name, :admin_user_id, :has_hypur, :has_payqwick
    
    menu priority: 3
  
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
        column :has_hypur
        column :has_payqwick
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
            f.input :admin_user_id, :label => 'Admin User', :as => :select, 
                :collection => AdminUser.all.map{|u| ["#{u.email}", u.id]}
            f.input :state_id, :label => 'State', :as => :select, 
                :collection => State.all.map{|u| ["#{u.name}", u.id]}
            f.input :has_hypur
            f.input :has_payqwick
        end
        f.actions
    end

end
