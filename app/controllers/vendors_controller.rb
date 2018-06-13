class VendorsController < ApplicationController
    
    before_action :set_vendor, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, except: [:show, :index]
    
    def index
        if @site_visitor_state.product_state?
            if marshal_load($redis.get("#{@site_visitor_state.name.downcase}_vendors")).blank?
                @vendors = Vendor.where(state_id: @site_visitor_state.id).order("RANDOM()")
                $redis.set("#{@site_visitor_state.name.downcase}_vendors", Marshal.dump(@vendors))
            else
                @vendors = Marshal.load($redis.get("#{@site_visitor_state.name.downcase}_vendors"))    
            end
            @vendors = @vendors.paginate(page: params[:page], per_page: 16)
        else
            @vendors = Vendor.order("RANDOM()").paginate(page: params[:page], per_page: 16)
        end
    end
    
    def refine_index
        
        result = VendorFinder.new(params).build
        
        #parse returns
        @vendors, @search_string, @searched_name, @az_letter =
                result[0], result[1], result[2], result[3]
        
        @vendors = @vendors.paginate(page: params[:page], per_page: 16)
        
        render 'index'
    end
    
    #-------------------------------------------

    def show
        if marshal_load($redis.get("#{@vendor.name.downcase}_products")).blank?
            @vendor_products = @vendor.products.featured.includes(:average_prices, :vendors, :category)
            $redis.set("#{@vendor.name.downcase}_products", Marshal.dump(@vendor_products))           
        else
            @vendor_products = Marshal.load($redis.get("#{@vendor.name.downcase}_products"))
        end
        @vendor_products = @vendor_products.paginate(:page => params[:page], :per_page => 8)
    end
  
    private
    
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                #flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end

        def set_vendor
            if marshal_load($redis.get("vendor_#{params[:id]}")).blank?
                @vendor = Vendor.friendly.find(params[:id])
                set_into_redis
            else
                get_from_redis
            end
            if @vendor.blank?
                redirect_to root_path 
            end
        end
        
        def set_into_redis
            $redis.set("vendor_#{params[:id]}", marshal_dump(@vendor))
        end

        def get_from_redis
            @vendor = marshal_load($redis.get("vendor_#{params[:id]}")) 
        end
        
end