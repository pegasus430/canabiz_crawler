class DispensariesController < ApplicationController
    before_action :set_dispensary, only: [:edit, :update, :destroy, :show, :all_products]
    before_action :require_admin, only: [:admin, :edit, :update, :destroy]
    
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

    #-------------------------------------

    def show
        
        require 'uri' #google map / facebook        
        @dispensary_source = DispensarySource.where(dispensary_id: @dispensary.id).
                        includes(dispensary_source_products: [:product, :dsp_prices], products: [:category, :vendors, :vendor, :average_prices]).
                        order('last_menu_update DESC').first
        @dispensary_source_products = @dispensary_source.dispensary_source_products.includes(:dsp_prices, :product)
        
        @category_to_products = Hash.new
        
        if @dispensary_source != nil
            @dispensary_source_products.each do |dsp|
            
                
                #dispensary_source_ids = @dispensary_source_products.pluck(:dispensary_source_id)
                #@dispensary_sources = DispensarySource.where(id: dispensary_source_ids).order('last_menu_update DESC')
                
                @matching_products = Product.where(id: @dispensary_source.dispensary_source_products.pluck(:product_id)).
                                        includes(:vendors, :category)            
                
                if dsp.product.present? && dsp.product.featured_product && dsp.product.category.present?
                    if @category_to_products.has_key?(dsp.product.category.name)
                        @category_to_products[dsp.product.category.name].push(dsp)
                    else
                        @category_to_products.store(dsp.product.category.name, [dsp])
                    end
                end
                
            end
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