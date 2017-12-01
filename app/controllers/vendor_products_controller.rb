class VendorProductsController < ApplicationController
    
    before_action :set_vendor_product, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, only: [:admin, :edit, :show, :index, :destroy, :update]
    #before_action :require_admin, except: [:show]

    #--------ADMIN PAGE-------------------------
    def admin
        @vendor_products = VendorProduct.order(sort_column + " " + sort_direction).paginate(page: params[:page], per_page: 50)
    
        respond_to do |format|
            format.html
            format.csv {render text: @vendor_products.to_csv }
        end
    end
    
    #method is used for csv file upload
    def import
        VendorProduct.import(params[:file])
        flash[:success] = 'Vendor Products were successfully imported'
        redirect_to vendor_products_admin_path 
    end
    
    #--------ADMIN PAGE-------------------------
    
    #-----------------------------------
    def new
      @vendor_product = VendorProduct.new
    end
    def create
      @vendor_product = VendorProduct.new(vendor_product_params)
      if @vendor_product.save
         flash[:success] = 'Vendor Product was successfully created'
         redirect_to vendor_products_admin_path
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
        if @vendor_product.update(vendor_product_params)
            flash[:success] = 'Vendor Product was successfully updated'
            redirect_to vendor_products_admin_path
        else 
            render 'edit'
        end
    end
    #-------------------------------------
   
    def destroy
        @vendor_product.destroy
        flash[:success] = 'Vendor Product was successfully deleted'
        redirect_to vendor_products_admin_path
    end  
    
    def destroy_multiple
      VendorProduct.destroy(params[:vendor_products])
      flash[:success] = 'Vendor Products were successfully deleted'
      redirect_to vendor_products_admin_path        
    end 
    
    #-------------------------------------
    private 
        
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end
        def set_vendor_product
            @vendor_product = VendorProduct.find(params[:id])
        end
        
        def vendor_product_params
            params.require(:vendor_product).permit(:product_id, :vendor_id, :units_sold)
        end
        
        def sort_column
            params[:sort] || "vendor_id"
        end
        def sort_direction
            params[:direction] || 'desc'
        end 
end