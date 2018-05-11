class AveragePricesController < ApplicationController

    before_action :set_average_price, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, only: [:edit, :update, :destroy, :admin]
    
    
    def show
        @product = @average_price.product
        @dispensary_source_products = DispensarySourceProduct.
                where(product: @product).
                where('dsp_prices.unit like ?', @average_price.average_price_unit).
                where('dsp_prices.price <= ?', @average_price.average_price).
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
end