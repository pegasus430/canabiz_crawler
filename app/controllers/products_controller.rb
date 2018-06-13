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
        
        if @site_visitor_state.present? && @site_visitor_state.product_state
            @products = @site_visitor_state.products.featured.order('RANDOM()').
                    includes(:vendors, :category, :average_prices)
        else 
            @products = Product.featured.left_join(:dispensary_source_products).group(:id).
                    order('COUNT(dispensary_source_products.id) DESC').
                    includes(:vendors, :category, :average_prices)    
        end
        
        if @searched_category.present?
            
            @products = @products.where(category_id: @searched_category.id)
            @search_string = @searched_category.name
        
        elsif @searched_sub_category.present? 
        
            @products = @products.where(sub_category: @searched_sub_category).where(is_dom: nil)
            @search_string = @searched_sub_category
        
        elsif @searched_is_dom.present?    
        
            @products = @products.where(is_dom: @searched_is_dom)
            @search_string = "Hybrid-#{@searched_is_dom}"
        end
        
        #search string
        if @search_string.present? && @site_visitor_state.product_state
            @search_string = "#{@search_string} in #{@site_visitor_state.name}"  
        
        elsif @search_string.present? && !@site_visitor_state.product_state
            
            state_string = ''
            @states_with_products.each do |state|
                state_string = state_string + state.name + ', ' 
            end
            state_string.chomp(', ')
            @search_string = "#{@search_string} in #{state_string}"
        end

        @products = @products.paginate(page: params[:page], per_page: 16)

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
        
        puts 'here are the params:'
        puts params
        #only show featured product
        if @product.featured_product == false
            redirect_to root_path 
        end
        begin
          result = ProductHelper.new(@product, @site_visitor_state).buildProductDisplay
            @similar_products, @dispensary_to_product, @table_header_options = 
                    result[0], result[1], result[2]    
        rescue => ex
            puts 'here is the error: '
            puts ex
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
                
                @similar_products, @dispensary_to_product, @table_header_options = 
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
            if marshal_load($redis.get("product_#{params[:id]}")).blank?
                @product = Product.friendly.find(params[:id])
                set_into_redis
            else
                get_from_redis
            end
            if @product.blank?
                redirect_to root_path 
            end
        end
        
        def set_into_redis
            $redis.set("product_#{params[:id]}", marshal_dump(@product))
        end

        def get_from_redis
            @product = marshal_load($redis.get("product_#{params[:id]}")) 
        end
end