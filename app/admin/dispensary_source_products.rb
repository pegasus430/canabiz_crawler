ActiveAdmin.register DispensarySourceProduct, as: "Dispensary Products" do
    menu priority: 5
    permit_params :dispensary_source_id, :product_id, dsp_prices_attributes: [:id, :price, :unit, :_destroy]
    
    #save queries
    includes :dispensary_source, :product
  
    #scopes
	scope :all, default: true
	scope :for_featured
    
    index do
        if current_admin_user.admin?
            selectable_column
            column :id
            column "Dispensary Source" do |dsp|
                if dsp.dispensary_source.present? && dsp.dispensary_source.source.present?
                    link_to "#{dsp.dispensary_source.name} - #{dsp.dispensary_source.source.name}", admin_dispensary_source_path(dsp.dispensary_source)
                end
            end
            column "Product" do |dsp|
                if dsp.product.present?
                    link_to dsp.product.name , admin_product_path(dsp.product)
                end
            end
            column "Product Category" do |dsp|
                if dsp.product.present? && dsp.product.category.present? 
                    link_to dsp.product.category.name , admin_category_path(dsp.product.category)
                end
            end
            column :created_at
            column :updated_at
            actions
        else
        render 'admin/dispensary_source_products/index', context: self
        end
    end

  form url: "/admin/dispensary_products/add_to_store"  do |f|
    panel '' do
      f.input :product_id, :label => 'Product', :as => :select, 
          :collection => Product.order('name ASC').map{|u| ["#{u.name}", u.id]}, include_blank: false
      
      if f.object.persisted?
          f.input :dispensary_source_id, :label => 'Dispensary Source', :as => :select, 
            :collection => DispensarySource.order('name ASC').map{|u| ["#{u.name} - #{u.source_id}", u.id]}
        	f.input :dispensary_source_product_id, :input_html => { :value => f.object.id }, as: :hidden
      end
      if !(f.object.persisted?) && current_admin_user.admin?
        f.input :dispensary_source_id, :label => 'DispensarySource', :as => :select, :collection => DispensarySource.all.map{|u| ["#{u.name}", u.id]}, include_blank: false
      end 
      
      if current_admin_user.dispensary_admin_user?   
        f.inputs do
          f.has_many :dsp_prices, allow_destroy: true do |t|
            t.input :unit, :collection =>  DspPrice::UNIT_PRICES_OPTIONS.sort, :prompt => "Select Unit"      
            t.input :price
          end
        end
      end
    end
    f.actions
  end
  
    #ACTIONS FOR DISPENSARY ADMIN TO ADD / EDIT / REMOVE PRODUCTS FROM STORE
  collection_action :add_to_store, :method => :post do  
    if current_admin_user.admin?
      dispensary_source = DispensarySource.find_by_id(params[:dispensary_source_product][:dispensary_source_id])
    else    
      dispensary_source = current_admin_user.dispensary_source
    end
    product = Product.find_by(id: params[:dispensary_source_product][:product_id])
    if product
      dispensary_source_product = DispensarySourceProduct.new(params.require(:dispensary_source_product).permit!) 
      dispensary_source_product.dispensary_source_id = dispensary_source.id
      dispensary_source_product.save
    end
    redirect_to admin_dispensary_products_path
  end

  config.filters = false

  controller do
    def update
      dispensary_source_product = DispensarySourceProduct.find(params[:dispensary_source_product][:dispensary_source_product_id])
      if dispensary_source_product.update_attributes(permitted_params[:dispensary_source_product])
        redirect_to edit_admin_dispensary_product_path(dispensary_source_product)
      else
        render :edit
      end
    end

    def index
      if current_admin_user.admin?
        @dispensary_source_products = DispensarySourceProduct.all
      else
        @dispensary_source_products =  current_admin_user.dispensary_source.dispensary_source_products
      end
      @products = Product.all
    end
     
  end

end
