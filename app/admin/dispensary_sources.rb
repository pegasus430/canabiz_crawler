ActiveAdmin.register DispensarySource do
  
  menu label: 'Dispensary Info', url: "/admin/dispensary_sources/dispensary_info"

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
  
  # #ACTIONS FOR DISPENSARY ADMIN TO ADD / EDIT / REMOVE PRODUCTS FROM STORE
  # member_action :add_to_store, :method => :post do
  #   disp = DispensarySource.find(params[:id])
  #   product = Product.find_by(id: params[:product_id])
  #   dsp = DispensarySourceProduct.create(product_id: params[:product_id], 
  #     dispensary_source_id: disp.id) if product
    
  #   #create several dsp_prices with all the price and unit inputs
    
      
  #   #DspPrice.create(dispensary_source_product_id: dsp.id)
  
  #   redirect_to edit_admin_dispensary_source_path(disp)
  # end
  
  #delete product entirely from store
  member_action :delete_from_store, :method => :get do
    disp = DispensarySource.find(params[:id])
    dsp = DispensarySourceProduct.find_by(product_id: params[:product_id], 
              dispensary_source_id: disp.id)
    dsp.delete
    redirect_to edit_admin_dispensary_source_path(disp)
  end
  
  collection_action :dispensary_info, :method => :get do
    current_admin_user.dispensary_source
    if current_admin_user.admin?
      redirect_to admin_dispensary_sources_path
    else
      redirect_to admin_dispensary_source_path(current_admin_user.dispensary_source)
    end
  end
  
  #delete individual dsp_prices
  
  
  #in-line update multiple dsp_prices
  
  # member_action :update_product_store, :method => :put do
  #   store = Store.find(params[:id])
  #   product_store = ProductStore.find_by(id: params[:product_store_id])
  #   product_store.update_attributes(price: params[:price])
  #   render :json=> {product_store: product_store.reload}
  # end
  
  #use a partial for the form - app/views/admin/dispensary_sources
  form partial: 'form'
  
    
    index do
        column :name
    
    column "Image" do |dispensary|
          truncate(dispensary.image_url, omision: "...", length: 50) if dispensary.image
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
      column "Admin User" do |ds|
        link_to ds.admin_user.email, admin_admin_user_path(ds.admin_user_id) if ds.admin_user
      end
      column "State" do |ds|
        if ds.state.present?
          link_to ds.state.name, admin_state_path(ds.state_id)
        end
      end
    end

    column :location
    
    if !current_admin_user.admin?
      column  :instagram
      column  :twitter
      column  :website
      column  :email
      column  :phone, label: 'Phone Number'
      column  :min_age, label: 'Minimum Age'
      
      column  :monday_open_time
      column  :tuesday_open_time
      column  :wednesday_open_time
      column  :thursday_open_time
      column  :friday_open_time
      column  :saturday_open_time
      column  :sunday_open_time
      column  :monday_close_time
      column  :tuesday_close_time
      column  :wednesday_close_time
      column  :thursday_close_time
      column  :friday_close_time
      column  :saturday_close_time
      column  :sunday_close_time
    end
    
    column :updated_at
    #should make a new column thats like - awaiting approval - everytime they change it I set it
        actions
    end
    
  #  form(:html => { :multipart => true }) do |f|
    # f.inputs do
      
    #   # if current_admin_user.dispensary_admin_user?
    #   #   f.input :name, input_html: { disabled: true } 
    #   # end
      
    #   # if current_admin_user.admin?
    #   #   f.input :name
    #   #   f.input :admin_user_id, :label => 'Admin User', :as => :select, 
  # #             :collection => AdminUser.order('email ASC').map{|u| ["#{u.email}", u.id]}
    #   #   f.input :dispensary_id, :label => 'Dispensary', :as => :select, 
    #   #       :collection => Dispensary.order('name ASC').map{|u| ["#{u.name}", u.id]}
    #   #   f.input :source_id, :label => 'Source', :as => :select, 
    #   #       :collection => Source.where(source_type: ['Dispensary', 'Both']).order('name ASC').
    #   #               map{|u| ["#{u.name}", u.id]}
    #   #   f.input :state_id, :label => 'State', :as => :select, 
    #   #     :collection => State.order('name ASC').map{|u| ["#{u.name}", u.id]}
    #   #   f.input :source_rating
    #   #   f.input :last_menu_update
    #   # end
      
    #   f.input :image, :as => :file
    #   f.input :street
    #   f.input :city
    #   f.input :zip_code
      
    #   f.input :instagram
    #     f.input :twitter
    #     f.input :website
    #     f.input :email
    #     f.input :phone, label: 'Phone Number'
    #     f.input :min_age, label: 'Minimum Age'
        
    #     f.input :monday_open_time, :as => :time_picker
    #   f.input :monday_close_time, :as => :time_picker
    #   f.input :tuesday_open_time, :as => :time_picker
    #   f.input :tuesday_close_time, :as => :time_picker
    #   f.input :wednesday_open_time, :as => :time_picker
    #   f.input :wednesday_close_time, :as => :time_picker
    #   f.input :thursday_open_time, :as => :time_picker
    #   f.input :thursday_close_time, :as => :time_picker
    #   f.input :friday_open_time, :as => :time_picker
    #   f.input :friday_close_time, :as => :time_picker
    #   f.input :saturday_open_time, :as => :time_picker
    #   f.input :sunday_open_time, :as => :time_picker
    #   f.input :saturday_close_time, :as => :time_picker
    #   f.input :sunday_close_time, :as => :time_picker
    # end
    # f.actions
  #  end
  
  
end
