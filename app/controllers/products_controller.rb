class ProductsController < ApplicationController

    before_action :set_product, only: [:edit, :update, :destroy, :show, :change_state]
    before_action :require_admin, only: [:admin, :edit, :update, :delete]

    def index
        
        if params[:format].present?
            
            @searched_category = @product_categories.find_by(name: params[:format])
            
            if !@searched_category.present?
                if params[:format] == 'Hybrid-Indica'
                    @searched_is_dom = 'Indica'
                elsif params[:format] == 'Hybrid-Sativa'
                    @searched_is_dom = 'Sativa'
                else
                    @searched_sub_category = params[:format] 
                end
            end
        end
        
        @products = Product.featured.left_join(:dispensary_source_products).group(:id).
                    order('COUNT(dispensary_source_products.id) DESC').
                    includes(:vendors, :category, :average_prices)

        if @searched_category.present?
            
            @products = @products.where(category_id: @searched_category.id)
            @search_string = "#{@searched_category.name} in #{@site_visitor_state.name}"
        
        elsif @searched_sub_category.present? 
        
            @products = @products.where(sub_category: @searched_sub_category).where(is_dom: nil)
            @search_string = "#{@searched_sub_category} in #{@site_visitor_state.name}"
        
        elsif @searched_is_dom.present?    
        
            @products = @products.where(is_dom: @searched_is_dom)
            @search_string = "Hybrid-#{@searched_is_dom} in #{@site_visitor_state.name}"
        
        else
            @search_string = @site_visitor_state.name
        end

        @products = @products. #order("dsp_count DESC").
                        paginate(page: params[:page], per_page: 16)

    end
    
    def refine_index
        
        result = ProductFinder.new(params).build
        
        #parse returns
        @products, @search_string, @searched_name, @az_letter, 
            @searched_category, @searched_location, @searched_state = 
                result[0], result[1], result[2], result[3], result[4], result[5], result[6]
        
        @products = @products.paginate(page: params[:page], per_page: 16)
        
        render 'index' 
    end
    
    #------------------------------------
    
    def show
        #only show featured product
        if @product.featured_product == false
            redirect_to root_path 
        end
        
        begin 
            result = ProductHelper.new(@product, @site_visitor_state).buildProductDisplay
            
            @similar_products, @dispensary_to_product, @table_headers, @table_header_options = 
                    result[0], result[1], result[2], result[3]
                    
        rescue
            redirect_to root_path
        end
    end
    
    def change_state
        
        #only show featured product
        if @product.featured_product == false
            redirect_to root_path 
        end

        if params[:State] != nil 
            begin 
                @searched_state = State.where(name: params[:State]).first
                result = ProductHelper.new(@product, @searched_state).buildProductDisplay
                
                @similar_products, @dispensary_to_product, @table_headers = 
                        result[0], result[1], result[2]
                        
                render 'show'
            rescue
                redirect_to root_path
            end
        else
          redirect_to root_path 
        end
        
    end
  
    private
    
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                #flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end
        
        def set_product
          @product = Product.friendly.find(params[:id])
        end
        
        def product_params
          params.require(:product).permit(:name, :product_type, :image, :remote_image_url, 
                                            :ancillary, :featured_product, :alternate_names,
                                            :sub_category, :cbd, :cbn, :min_thc, :med_thc, :max_thc, :is_dom,
                                            :year, :month, :category_id, :description, dispensary_source_ids: [], vendor_ids: [])
        end  
end