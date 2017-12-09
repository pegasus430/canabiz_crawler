class VendorsController < ApplicationController
    
    before_action :set_vendor, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, only: [:admin, :edit, :show, :index, :destroy, :update]
    #before_action :require_admin, except: [:show, :index]

    #--------ADMIN PAGE-------------------------
    def admin
        
        @vendors = Vendor.order(sort_column + " " + sort_direction).paginate(page: params[:page], per_page: 50)
        #for csv downloader
        respond_to do |format|
            format.html
            format.csv {render text: @vendors.to_csv }
        end
    end
    
    #method is used for csv file upload
    def import
        Vendor.import(params[:file])
        flash[:success] = 'Vendors were successfully imported'
        redirect_to vendor_admin_path 
    end
    
    def search
        @q = "%#{params[:query]}%"
        @vendors = Vendor.where("name LIKE ?", @q).order(sort_column + " " + 
                                    sort_direction).paginate(page: params[:page], per_page: 50)
        render 'admin'
    end
    #--------ADMIN PAGE-------------------------
    
    def index
        @vendors = Vendor.all 
    end
    
    #-------------------------------------------
    def new
      @vendor = Vendor.new
    end
    def create
        @vendor = Vendor.new(vendor_params)
        if @vendor.save
            flash[:success] = 'Vendor was successfully created'
            redirect_to vendor_admin_path
        else 
            render 'new'
        end
    end
    
    #-------------------------------------------
    
    def show

    end

    #-------------------------------------------
    
    def edit
    end   
    def update
        if @vendor.update(vendor_params)
            flash[:success] = 'Vendor was successfully updated'
            redirect_to vendor_admin_path
        else 
            render 'edit'
        end
    end 
    
    #-------------------------------------------
   
    def destroy
        @vendor.destroy
        flash[:success] = 'Vendor was successfully deleted'
        redirect_to vendor_admin_path
    end
   
    def destroy_multiple
        Vendor.destroy(params[:vendors])
        flash[:success] = 'Vendors were successfully deleted'
        redirect_to vendor_admin_path        
    end
    
    #-------------------------------------------

  
    private
    
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end
        
        def set_vendor
          @vendor = Vendor.friendly.find(params[:id])
        end
        
        def vendor_params
          params.require(:vendor).permit(:name, :description, :linkedin_name, :twitter_name, :year_of_establishment, :specialization, 
                                            :website, :facebook_link, :image, :remote_image_url, product_ids:[])
        end  
        
        def sort_column
            params[:sort] || "name"
        end
        def sort_direction
            params[:direction] || 'desc'
        end
end