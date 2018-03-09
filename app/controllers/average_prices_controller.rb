class AveragePricesController < ApplicationController

    before_action :set_average_price, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, only: [:edit, :update, :destroy, :admin]
    
    #--------ADMIN PAGE-------------------------
    def admin
        @average_prices = AveragePrice.order(sort_column + " " + sort_direction)
                        .paginate(page: params[:page], per_page: 100)
    
        #for csv downloader
        respond_to do |format|
            format.html
            format.csv {render text: AveragePrice.all.to_csv }
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
        @product = @average_price.product
        @dispensary_source_products = DispensarySourceProduct.
                where(product: @product).
                where('dsp_prices.unit like ?', @average_price.average_price_unit).
                where('dsp_prices.price <= ', @average_price.average_price)
                joins(:dsp_prices)
                
        dispensary_source_ids = @dispensary_source_products.pluck(:dispensary_source_id)
        @dispensary_sources = DispensarySource.where(id: dispensary_source_ids).order('last_menu_update DESC')
        
        #need a map of dispensary to dispensary source product
        @dispensary_to_product = Hash.new
        
        @dispensary_sources.each do |dispSource|
            
            #dispensary products
            if !@dispensary_to_product.has_key?(dispSource.id)
               
                if @dispensary_source_products.where(dispensary_source_id: dispSource.id).any?
                    @dispensary_to_product.store(dispSource.id, 
                        @dispensary_source_products.where(dispensary_source_id: dispSource.id).first)
                end
            end
        end
    end
    
    
    def old_show
        @product = @average_price.product
        #find all places selling for that product and that unit
        
        #map of average_price_unit to DispensarySourceProduct field for query`
        @unit_to_field = Hash.new
        @unit_to_field.store('Half Gram', 'price_half_gram');
        @unit_to_field.store('Gram', 'price_gram');
        @unit_to_field.store('2 Grams', 'price_two_grams');
        @unit_to_field.store('Eighth', 'price_eighth');
        @unit_to_field.store('4 Grams', 'price_four_grams');
        @unit_to_field.store('Quarter Ounce', 'price_quarter');
        @unit_to_field.store('Half Ounce', 'price_half_ounce');
        @unit_to_field.store('Ounce', 'price_ounce');
        
        @dispensary_source_products = DispensarySourceProduct.where(product: @product).
            where("#{@unit_to_field[@average_price.average_price_unit]} <= ?", @average_price.average_price).
            where("#{@unit_to_field[@average_price.average_price_unit]} != ?", 0.0)
        
        dispensary_source_ids = @dispensary_source_products.pluck(:dispensary_source_id)
        @dispensary_sources = DispensarySource.where(id: dispensary_source_ids).order('last_menu_update DESC')
        
        #need a map of dispensary to dispensary source product
        @dispensary_to_product = Hash.new
        
        @dispensary_sources.each do |dispSource|
            
            #dispensary products
            if !@dispensary_to_product.has_key?(dispSource.id)
               
                if @dispensary_source_products.where(dispensary_source_id: dispSource.id).any?
                    @dispensary_to_product.store(dispSource.id, 
                        @dispensary_source_products.where(dispensary_source_id: dispSource.id).first)
                end
            end
        end
        
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
            params.require(:average_price).permit(:average_price, :average_price_unit, 
                                :display_order, :units_sold, :product_id)
        end
      
        def sort_column
            params[:sort] || "product_id"
        end
        def sort_direction
            params[:direction] || 'desc'
        end
          
end