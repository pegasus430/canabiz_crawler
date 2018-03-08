class StatesController < ApplicationController
    
    before_action :set_state, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, only: [:edit, :update, :destroy, :admin]

    def index
    end

    def admin
        @states = State.all.order("name ASC")
        
        #method is used for csv file upload
        def import
            State.import(params[:file])
            flash[:success] = 'States were successfully imported'
            redirect_to states_admin_path 
        end        
    
        #for csv downloader
        respond_to do |format|
            format.html
            format.csv {render text: @states.to_csv }
        end
    end
    
    def new
      @state = State.new
    end
    
    def create
      @state = State.new(state_params)
      if @state.save
         flash[:success] = 'State was successfully created'
         redirect_to states_admin_path
      else 
         render 'new'
      end
    end 
    
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
                                    #order("dsp_count DESC").
                                    paginate(:page => params[:page], :per_page => 16)
            @search_string = @state.name
        else
            @mostviews = @state.articles.active_source.
                        includes(:source, :categories, :states).
                        order("num_views DESC").
                        paginate(:page => params[:page], :per_page => 24)
        end

        expires_in 10.minutes, :public => true
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
    
    def edit
    end   
   
   def update
      if @state.update(state_params)
         flash[:success] = 'State was successfully updated'
         redirect_to states_admin_path
      else 
         render 'edit'
      end
   end 
   
   def destroy
      @state.destroy
      flash[:success] = 'State was successfully deleted'
      redirect_to states_admin_path
   end    
    
    private 
        def set_state
            @state = State.friendly.find(params[:id])
        end
        def state_params
            params.require(:state).permit(:name, :abbreviation, :timezone_id, :keywords, 
                            :logo, :slug, :product_state, dispensary_ids: [])
        end  
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                redirect_to root_path
            end
        end
    
end