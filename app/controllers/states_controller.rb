class StatesController < ApplicationController
    
    before_action :set_state, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, only: [:edit, :update, :destroy, :admin]

    def show
        #state articles
        @recents = @state.articles.active_source.
                        includes(:source, :categories, :states).
                        order("created_at DESC").
                        paginate(:page => params[:page], :per_page => 24)
        
        #state products
        if @state.product_state
            #get products available at dispensaries in state
            @products = Product.featured.includes(:dispensary_sources, :vendors, :category, :average_prices).
                                    where(:dispensary_sources => {state_id: @state.id}).
                                    paginate(:page => params[:page], :per_page => 16)
            @search_string = @state.name
        else
            @mostviews = @state.articles.active_source.
                        includes(:source, :categories, :states).
                        order("num_views DESC").
                        paginate(:page => params[:page], :per_page => 24)
        end

    end
    
    #refine the products on the state index
    def refine_products
        @state = State.where(id: params[:state_id]).first
        
        #state articles
        @recents = @state.articles.active_source.order("created_at DESC").paginate(:page => params[:page], :per_page => 24)
        #@mostviews = @state.articles.active_source.order("num_views DESC").paginate(:page => params[:page], :per_page => 24)
        
        #state products
        params[:state_search] = @state.name
        result = ProductFinder.new(params).build
        
        #parse returns
        @products, @search_string, @searched_name, @az_letter, 
            @searched_category, @searched_location, @searched_state = 
                result[0], result[1], result[2], result[3], result[4], result[5], result[6]
        
        @products = @products.paginate(page: params[:page], per_page: 16)
        
        render 'show'
    end
    
    private 

        def set_state
            @state = State.friendly.find(params[:id])
        end
end