class AveragePricesController < ApplicationController

    before_action :set_average_price, only: [:edit, :update, :destroy, :show]
    
    #--------ADMIN PAGE-------------------------
    def admin
        @average_prices = AveragePrice.order(sort_column + " " + sort_direction)
                        .paginate(page: params[:page], per_page: 100)
    
        #for csv downloader
        respond_to do |format|
            format.html
            format.csv {render text: @average_prices.to_csv }
        end
    end
    
    #method is used for csv file upload
    def import
        AveragePrice.import(params[:file])
        flash[:success] = 'AveragePrices were successfully imported'
        redirect_to average_price_admin_path 
    end
    
    def search
        @q = "%#{params[:query]}%"
        @average_prices = AveragePrice.where("title LIKE ? or abstract LIKE ?", @q, @q)
                            .order(sort_column + " " + sort_direction)
                            .paginate(page: params[:page], per_page: 24)
        render 'admin'
    end
    
    
    #--------ADMIN PAGE-------------------------
    
    def index

    end
    

    def new
      @average_price = AveragePrice.new
    end
    
    def create
        @average_price = AveragePrice.new(average_price_params)
        
        if @average_price.save
            flash[:success] = 'Article was successfully created'
            redirect_to average_price_admin_path
        else 
            render 'new'
        end
    end 
    #-----------------------------------
    
    def show

    end
    
    
    #-----------------------------------
    def edit
    end   
    def update
        if @average_price.update(average_price_params)
            flash[:success] = 'Article was successfully updated'
            redirect_to average_price_admin_path
        else 
            render 'edit'
        end
    end 
    #-----------------------------------
   
    def destroy
        @average_price.destroy
        flash[:success] = 'Article was successfully deleted'
        redirect_to average_price_admin_path
    end 
   
    def destroy_multiple
      AveragePrice.destroy(params[:average_prices])
      flash[:success] = 'Average Prices were successfully deleted'
      redirect_to average_price_admin_path        
    end   
    
    private 
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                redirect_to root_path
            end
        end
        
        def set_average_price
            @average_price = AveragePrice.find(params[:id])
            if @average_price.blank?
                redirect_to root_path 
            end
        end
        def average_price_params
            params.require(:average_price).permit(:average_price, :average_price_unit, :units_sold, :product_id)
        end
      
        def sort_column
            params[:sort] || "product_id"
        end
        def sort_direction
            params[:direction] || 'desc'
        end
          
end