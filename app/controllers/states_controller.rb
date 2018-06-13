class StatesController < ApplicationController
    
    before_action :set_state, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, only: [:edit, :update, :destroy, :admin]

    def show
        
        #state articles
        if marshal_load($redis.get("#{@state.name.downcase}_recent_articles")).blank?
            @recents = @state.articles.active_source.includes(:source, :categories, :states).
                            order("created_at DESC")
            $redis.set("#{@state.name.downcase}_recent_articles", Marshal.dump(@recents))           
        else
            @recents = Marshal.load($redis.get("#{@state.name.downcase}_recent_articles"))
        end
        
        @recents = @recents.paginate(:page => params[:page], :per_page => 24)
        
        #state products
        # if @state.product_state
        #     #get products available at dispensaries in state
        #     @products = Product.featured.includes(:dispensary_sources, :vendors, :category, :average_prices).
        #                             where(:dispensary_sources => {state_id: @state.id}).
        #                             paginate(:page => params[:page], :per_page => 16)
        #     @search_string = @state.name
        # else
            
            if marshal_load($redis.get("#{@state.name.downcase}_mostview_articles")).blank?
                @mostviews = @state.articles.active_source.includes(:source, :categories, :states).
                                order("num_views DESC")
                $redis.set("#{@state.name.downcase}_mostview_articles", Marshal.dump(@mostviews))           
            else
                @mostviews = Marshal.load($redis.get("#{@state.name.downcase}_mostview_articles"))
            end
            
            @mostviews = @mostviews.paginate(:page => params[:page], :per_page => 24)
            
        # end
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
            if marshal_load($redis.get("state_#{params[:id]}")).blank?
                @state = State.friendly.find(params[:id])
                set_into_redis
            else
                get_from_redis
            end     
            if @state.blank?
                redirect_to root_path 
            end
        end

        def set_into_redis
            $redis.set("state_#{params[:id]}", marshal_dump(@state))
        end

        def get_from_redis
            @state = marshal_load($redis.get("state_#{params[:id]}")) 
        end
end