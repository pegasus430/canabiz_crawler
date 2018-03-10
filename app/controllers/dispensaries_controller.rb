class DispensariesController < ApplicationController
    before_action :set_dispensary, only: [:edit, :update, :destroy, :show, :all_products]
    before_action :require_admin, only: [:admin, :edit, :update, :destroy]
    before_action :site_visitor_state, only: [:index, :show]

    #--------ADMIN PAGE-------------------------
    def admin
        @dispensaries = Dispensary.order(sort_column + " " + sort_direction).paginate(page: params[:page], per_page: 50)
    
        respond_to do |format|
            format.html
            format.csv {render text: @dispensaries.to_csv }
        end
    end
    
    #method is used for csv file upload
    def import_via_csv
        Dispensary.import_via_csv(params[:file])
        flash[:success] = 'Dispensaries were successfully imported'
        redirect_to dispensary_admin_path 
    end
    
    def search
        query = "%#{params[:query]}%"
        @dispensaries = Dispensary.where("name LIKE ? or location LIKE ? or city LIKE ?", query, query, query).order(sort_column + " " + 
                                    sort_direction).paginate(page: params[:page], per_page: 50)
        render 'admin'
    end
    
    #--------ADMIN PAGE-------------------------
    
    def index
        
        if @site_visitor_state != nil
            @dispensaries = Dispensary.where(state: @site_visitor_state).
                                order("name ASC").paginate(page: params[:page], per_page: 16)
            @search_string = @site_visitor_state.name
        else
            @dispensaries = Dispensary.order("name ASC").paginate(page: params[:page], per_page: 16)
        end
        
        #az-list
        
        
    end
    
    def refine_index
        
        result = DispensaryFinder.new(params).build
        
        #parse returns
        @dispensaries, @search_string, @searched_name, @az_letter, 
            @searched_location, @searched_state = 
                result[0], result[1], result[2], result[3], result[4], result[5]
        
        
        @dispensaries = @dispensaries.paginate(page: params[:page], per_page: 16)
        
        render 'index'
    end
    
    #-----------------------------------
    def new
      @dispensary = Dispensary.new
    end
    def create
      @dispensary = Dispensary.new(dispensary_params)
      if @dispensary.save
         flash[:success] = 'Dispensary was successfully created'
         redirect_to dispensary_admin_path
      else 
         render 'new'
      end
    end 
    #-------------------------------------

    def show
        
        @dispensary_source = DispensarySource.where(dispensary_id: @dispensary.id).
                        includes(dispensary_source_products: [:product, :dsp_prices]).
                        order('last_menu_update DESC').first
                                
        if @dispensary_source != nil
            
            #dispensary_source_ids = @dispensary_source_products.pluck(:dispensary_source_id)
            #@dispensary_sources = DispensarySource.where(id: dispensary_source_ids).order('last_menu_update DESC')
            
            @matching_products = Product.where(id: @dispensary_source.dispensary_source_products.pluck(:product_id)).
                                    includes(:vendors, :category)
            
            @category_to_products = Hash.new
            @category_to_products.store('Flower', @dispensary_source.dispensary_source_products)
            
            require 'uri' #google map / facebook
        else 
            redirect_to root_path
        end
        
    end
    
    #-------------------------------------    
    def edit
    end   
    def update
        if @dispensary.update(dispensary_params)
            flash[:success] = 'Dispensary was successfully updated'
            redirect_to dispensary_admin_path
        else 
            render 'edit'
        end
    end
    #-------------------------------------
   
    def destroy
        @dispensary.destroy
        flash[:success] = 'Dispensary was successfully deleted'
        redirect_to dispensary_admin_path
    end  
    
    def destroy_multiple
      Dispensary.destroy(params[:dispensaries])
      flash[:success] = 'Dispensaries were successfully deleted'
      redirect_to dispensary_admin_path        
    end 
    
    #-------------------------------------
    private 
        
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                #flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end
        def set_dispensary
            @dispensary = Dispensary.friendly.find(params[:id])
        end
        def dispensary_params
            params.require(:dispensary).permit(:name, :image, :location, :city, :state_id)
        end
        
        def sort_column
            params[:sort] || "name"
        end
        def sort_direction
            params[:direction] || 'asc'
        end
end