class DispensarySourceProductsController < ApplicationController
    
    before_action :set_dispensary_source_product, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, except: [:show]
    
    #-----------------------------------
    def new
      @dispensary_source_product = DispensarySourceProduct.new
    end
    def create
      @dispensary_source_product = DispensarySourceProduct.new(dispensary_source_product_params)
      if @dispensary_source_product.save
         flash[:success] = 'Dispensary Source Product was successfully created'
         redirect_to dispensary_source_products_admin_path
      else 
         render 'new'
      end
    end 
    #-------------------------------------

    def show
    end
    
    #-------------------------------------    
    def edit
    end       
    def update
        if @dispensary_source_product.update(dispensary_source_product_params)
            flash[:success] = 'Dispensary Source Product was successfully updated'
            redirect_to dispensary_source_products_admin_path
        else 
            render 'edit'
        end
    end
    #-------------------------------------
   
    def destroy
        @dispensary_source_product.destroy
        flash[:success] = 'Dispensary Source Product was successfully deleted'
        redirect_to dispensary_source_products_admin_path
    end  
    
    def destroy_multiple
      DispensarySourceProduct.destroy(params[:dispensary_source_products])
      flash[:success] = 'Dispensary Source Products were successfully deleted'
      redirect_to dispensary_source_products_admin_path        
    end 
    
    #-------------------------------------
    private 
        
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                #flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end
        def set_dispensary_source_product
            @dispensary_source_product = DispensarySourceProduct.find(params[:id])
        end
        
        def dispensary_source_product_params
            params.require(:dispensary_source_product).permit(:product_id, :dispensary_source_id)
        end
end