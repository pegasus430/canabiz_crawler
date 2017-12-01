class ProductsController < ApplicationController
    before_action :site_visitor_state, only: [:show, :index]
    before_action :set_product, only: [:edit, :update, :destroy, :show]
    before_action :site_visitor_ip, only: [:index, :refine_index]
    before_action :require_admin, only: [:admin, :edit, :show, :index, :destroy, :update, :refine_index]

    #--------ADMIN PAGE-------------------------
    def admin
        @requires_admin = true
        @products = Product.order(sort_column + " " + sort_direction).paginate(page: params[:page], per_page: 50)
        #for csv downloader
        respond_to do |format|
            format.html
            format.csv {render text: @products.to_csv }
        end
        
        #az-list
        @az_values = ['A','B','C','D','E','F','G','H','I','J','K','L','M',
                        'N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
    end
    
    #method is used for csv file upload
    def import
        Product.import(params[:file])
        flash[:success] = 'Products were successfully imported'
        redirect_to product_admin_path 
    end
    
    def search
        query = "%#{params[:query]}%"
        @products = Product.where("name LIKE ?", query).order(sort_column + " " + 
                                    sort_direction).paginate(page: params[:page], per_page: 50)
        
        #az-list
        @az_values = ['A','B','C','D','E','F','G','H','I','J','K','L','M',
                        'N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
                        
        render 'admin'
    end
    #--------ADMIN PAGE-------------------------
    
    def index
        
        if params[:format].present?
           @searched_category = Category.find_by(name: params[:format])
        end
        
        if @site_visitor_state != nil && @site_visitor_state.product_state
            
            @products = Product.featured.
                                includes(:dispensary_sources, :vendors, :category, :dispensary_sources => :dispensary).
                                where(:dispensary_sources => {state_id: @site_visitor_state.id})
                                    
            if @searched_category != nil 
                
                @products = @products.where(category_id: @searched_category.id)
                @search_string = "#{@searched_category.name} in #{@site_visitor_state.name}"
            else
                @search_string = @site_visitor_state.name
            end
            
            #price range and distance
            result = ProductHelper.new(@products, @site_visitor_ip).findProductsPriceAndDistance
            @product_to_distance, @product_to_closest_disp = result[0], result[1]
            
        else
            @products = Product.featured.order("name ASC").includes(:vendors, :category)
            if @searched_category != nil 
                @products = @products.where(category_id: @searched_category.id)
                @search_string = @searched_category.name
            else 
                @search_string = ''
            end
        end
        
        #az-list
        @az_values = ['A','B','C','D','E','F','G','H','I','J','K','L','M',
                        'N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
        
        @products = @products.paginate(page: params[:page], per_page: 16)

    end
    
    def refine_index
        
        result = ProductFinder.new(params).build
        
        #parse returns
        @products, @search_string, @searched_name, @az_letter, 
            @searched_category, @searched_location, @searched_state = 
                result[0], result[1], result[2], result[3], result[4], result[5], result[6]
        
        @products = @products.paginate(page: params[:page], per_page: 16)
        
        if @site_visitor_state != nil && @site_visitor_state.product_state
            #price range    
            result = ProductHelper.new(@products, @site_visitor_ip).findProductsPriceAndDistance
            @product_to_distance, @product_to_closest_disp = result[0], result[1]
        end
        
        #az-list
        @az_values = ['A','B','C','D','E','F','G','H','I','J','K','L','M',
                        'N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
        render 'index' 
    end
    
    #-------------------------------------------
    def new
      @product = Product.new
      #az-list
        @az_values = ['A','B','C','D','E','F','G','H','I','J','K','L','M',
                        'N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
    end
    def create
        @product = Product.new(product_params)
        if @product.save
            flash[:success] = 'Product was successfully created'
            redirect_to product_admin_path
        else 
            render 'new'
        end
    end
    
    #-------------------------------------------
    
    def show
        
        #only show featured product
        if @product.featured_product == false
            redirect_to root_path 
        end
        
        #similar products
        @similar_products = []
        if @product.category.present?
            @similar_products = @product.category.products.featured.where.not(id: @product.id).limit(4)

        end
        
        @dispensary_source_products = DispensarySourceProduct.where(product: @product)
        dispensary_source_ids = @dispensary_source_products.pluck(:dispensary_source_id)
        @dispensary_sources = DispensarySource.where(id: dispensary_source_ids).order('last_menu_update DESC')
        
        #need a map of dispensary to dispensary source product
        @dispensary_to_product = Hash.new
        @state_to_dispensary = Hash.new
        
        @dispensary_sources.each do |dispSource|
            
            #state dispensaries
            if @state_to_dispensary.has_key?(dispSource.state.name)
                @state_to_dispensary[dispSource.state.name].push(dispSource)
            else
                dispensaries = []
                dispensaries.push(dispSource)
                @state_to_dispensary.store(dispSource.state.name, dispensaries) 
            end
            
            #dispensary products
            if !@dispensary_to_product.has_key?(dispSource.id)
               
                if @dispensary_source_products.where(dispensary_source_id: dispSource.id).any?
                    @dispensary_to_product.store(dispSource.id, 
                        @dispensary_source_products.where(dispensary_source_id: dispSource.id).first)
                end
            end
        end
        
        #az-list
        @az_values = ['A','B','C','D','E','F','G','H','I','J','K','L','M',
                        'N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
    end

    #-------------------------------------------
    
    def edit
        @requires_admin = true
    end   
    def update
        if @product.update(product_params)
            flash[:success] = 'Product was successfully updated'
            redirect_to product_admin_path
        else 
            render 'edit'
        end
    end 
    
    #-------------------------------------------
   
    def destroy
        @product.destroy
        flash[:success] = 'Product was successfully deleted'
        redirect_to product_admin_path
    end
   
    def destroy_multiple
        Product.destroy(params[:products])
        flash[:success] = 'Products were successfully deleted'
        redirect_to product_admin_path        
    end
    
    #-------------------------------------------

  
    private
    
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end
        
        def set_product
          @product = Product.friendly.find(params[:id])
        end
        
        def product_params
          params.require(:product).permit(:name, :product_type, :image, :remote_image_url, :ancillary, :featured_product,
                                            :year, :month, :category_id, :description, dispensary_ids: [], vendor_ids: [])
        end  
        
        def sort_column
            params[:sort] || "name"
        end
        def sort_direction
            params[:direction] || 'desc'
        end
end