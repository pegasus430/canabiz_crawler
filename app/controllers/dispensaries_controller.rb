class DispensariesController < ApplicationController
    before_action :set_dispensary, only: [:edit, :update, :destroy, :show, :all_products]
    before_action :require_admin, only: [:admin, :edit, :update, :destroy]
    
    def index
        
        if @site_visitor_state.product_state?
            if marshal_load($redis.get("#{@site_visitor_state.name.downcase}_dispensaries")).blank?
                @dispensaries = Dispensary.where(state_id: @site_visitor_state.id).order("RANDOM()")
                $redis.set("#{@site_visitor_state.name.downcase}_dispensaries", Marshal.dump(@dispensaries))
            else
                @dispensaries = Marshal.load($redis.get("#{@site_visitor_state.name.downcase}_dispensaries"))    
            end
            @dispensaries = @dispensaries.paginate(page: params[:page], per_page: 16)
        else
            @dispensaries = Dispensary.order("RANDOM()").paginate(page: params[:page], per_page: 16)
        end
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
    
    #---------

    def show
        
        require 'uri' #google map / facebook
        
        if marshal_load($redis.get("#{@dispensary.name.downcase}_dispensary_source")).blank?
            @dispensary_source = @dispensary.dispensary_sources.order('last_menu_update DESC').first
            $redis.set("#{@dispensary.name.downcase}_dispensary_source", Marshal.dump(@dispensary_source))
        else
            @dispensary_source = Marshal.load($redis.get("#{@dispensary.name.downcase}_dispensary_source"))    
        end
        
        if marshal_load($redis.get("#{@dispensary.name.downcase}_category_to_products")).blank?
            
            @dispensary_source_products = @dispensary_source.dispensary_source_products.
                        includes(:dsp_prices, product: [:category, :vendors, :vendor])
            
            @category_to_products = Hash.new
            
            @dispensary_source_products.each do |dsp|
                
                if dsp.product.present? && dsp.product.featured_product && dsp.product.category.present?
                    if @category_to_products.has_key?(dsp.product.category.name)
                        @category_to_products[dsp.product.category.name].push(dsp)
                    else
                        @category_to_products.store(dsp.product.category.name, [dsp])
                    end
                end
            end
            $redis.set("#{@dispensary.name.downcase}_category_to_products", Marshal.dump(@category_to_products))           
        else
            @category_to_products = Marshal.load($redis.get("#{@dispensary.name.downcase}_category_to_products"))
        end
        
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
            if marshal_load($redis.get("dispensary_#{params[:id]}")).blank?
                @dispensary = Dispensary.friendly.find(params[:id])
                set_into_redis
            else
                get_from_redis
            end
            if @dispensary.blank?
                redirect_to root_path 
            end
        end
        
        def set_into_redis
            $redis.set("dispensary_#{params[:id]}", marshal_dump(@dispensary))
        end

        def get_from_redis
            @dispensary = marshal_load($redis.get("dispensary_#{params[:id]}")) 
        end
end