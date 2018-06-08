class ApplicationController < ActionController::Base

    protect_from_forgery with: :exception
    
    #shopping cart included on every page
    include CurrentCart
    
    #these methods will be called before every action
    before_action :populate_lists, :skip_for_admin?, :site_visitor_location, :set_cart
    
    helper_method :current_user, :logged_in?
  
    def skip_for_admin?
        current_admin_user.blank?
    end
    
    def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
    
    def logged_in?
    !!current_user
    end
  
    def require_user
        if !logged_in?
            flash[:danger] = "You must be logged in to perform that action"
            redirect_to root_path
        end
    end
    
    def require_admin
        if !logged_in? || (logged_in? and !current_user.admin?)
            redirect_to root_path
        end
    end
  
    def site_visitor_location
        begin
            default_visitor_location
            if session[:state_id] != nil
                @site_visitor_state = State.where(id: session[:state_id]).first
            elsif request.location && request.location.state
                @site_visitor_state = State.where(name: request.location.state).first
            
                if @site_visitor_state.product_state
                    @site_visitor_city = request.location.city
                    @site_visitor_zip = request.location.zip_code
                    @site_visitor_ip = request.location.ip
                    session[:state_id] = @site_visitor_state.id
                    session[:product_state] = true
                else
                    default_visitor_location    
                end
            else
                default_visitor_location
            end
        rescue => ex
            default_visitor_location
        end
    end
    
    def default_visitor_location
        @site_visitor_state = State.where(name: 'Colorado').first
        @site_visitor_city = 'Seattle'
        @site_visitor_zip = '98101'
        @site_visitor_ip = '75.172.101.74'
        session[:state_id] = @site_visitor_state.id
        session[:product_state] = false
    end
  
    def populate_lists
        require 'will_paginate/array'
        
        # @redis = @redis || Redis.new(host: 'ec2-35-168-107-180.compute-1.amazonaws.com', 
        #                     port: 9979, password: 'p384db25b425919fe4297a5aa76d4ebea27858fb42d40ec0864e358f1516e5c57')

        
        # @news_categories = Category.news.active.order("name ASC") 
        #@product_categories = Category.products.active.order("name ASC")
        #@all_states = State.all.order("name ASC")
        # @states_with_products = @all_states.where(product_state: true)
        # @active_sources = Source.where(:active => true).order("name ASC")
        
        

        # if $redis.get("news_categories").blank?
        #   @news_categories = Category.news.active.order("name ASC") 
        #   @product_categories = Category.products.active.order("name ASC")
        #   @all_states = State.all.order("name ASC")
        #   @states_with_products = @all_states.where(product_state: true)
        #   @active_sources = Source.where(:active => true).order("name ASC")
        #   set_into_redis
        # else
        #   get_from_redis
        # end
        
        
        if $redis.get('news_categories').blank?
            @news_categories = Category.news.active.order("name ASC")
            $redis.set("news_categories", Marshal.dump(@news_categories))
        else 
            @news_categories = Marshal.load($redis.get("news_categories"))
        end
        
        if $redis.get('product_categories').blank?
            @product_categories = Category.products.active.order("name ASC")
            $redis.set("product_categories", Marshal.dump(@product_categories))
        else 
            @product_categories = Marshal.load($redis.get("product_categories"))
        end
        
        if $redis.get('all_states').blank?
            @all_states = State.all.order("name ASC")
            $redis.set("all_states", Marshal.dump(@all_states))
        else 
            @all_states = Marshal.load($redis.get("all_states"))
        end
        
        if $redis.get('states_with_products').blank?
            @states_with_products = @all_states.where(product_state: true)
            $redis.set("states_with_products", Marshal.dump(@states_with_products))
        else 
            @states_with_products = Marshal.load($redis.get("states_with_products"))
        end
        
        if $redis.get('active_sources').blank?
            @active_sources = Source.where(:active => true).order("name ASC")
            $redis.set("active_sources", Marshal.dump(@active_sources))
        else 
            @active_sources = Marshal.load($redis.get("active_sources"))
        end

        @az_values = ['#', 'A','B','C','D','E','F','G','H','I','J','K','L','M',
                            'N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
    end
  
    #redirect to homepage on error
    rescue_from ActionView::MissingTemplate, :with => :handle_error
    rescue_from ActiveRecord::RecordNotFound, :with => :handle_error
    rescue_from ActiveRecord::StatementInvalid, :with => :handle_error
    rescue_from ActionController::RoutingError, :with => :handle_error
    
    private
  
      def handle_error
        if Rails.env.Production? 
            redirect_to root_path
        end
      end

      def set_into_redis
        $redis.set("product_categories", marshal_dump(@product_categories))
        $redis.set("news_categories", marshal_dump(@news_categories))
        $redis.set("all_states", marshal_dump(@all_states))
        $redis.set("states_with_products", marshal_dump(@states_with_products))
        $redis.set("active_sources", marshal_dump(@active_sources))
      end

      def get_from_redis
        @news_categories = marshal_load($redis.get("news_categories")) 
        @product_categories = marshal_load($redis.get("product_categories"))
        @all_states = marshal_load($redis.get("all_states"))
        @states_with_products = marshal_load($redis.get("states_with_products"))
        @active_sources = marshal_load($redis.get("active_sources"))
      end

      def marshal_dump(object)
        data = Marshal.dump(object)
        data
      end

      def marshal_load(data)
         object = Marshal.load(data) rescue nil
         object
      end
end
