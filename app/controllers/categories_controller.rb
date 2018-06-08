class CategoriesController < ApplicationController
    
    before_action :set_category, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, except: [:show]
    
    def show
        
        if @category.category_type != 'News'
            redirect_to root_path 
        end
        
        if marshal_load($redis.get("#{@category.name.downcase}_recent_articles")).blank?
            @recents = @category.articles.active_source.
                        includes(:source, :categories, :states).
                        order("created_at DESC").
                        paginate(:page => params[:page], :per_page => 24)
            $redis.set("#{@category.name.downcase}_recent_articles", Marshal.dump(@recents))           
        else
            @recents = Marshal.load($redis.get("#{@category.name.downcase}_recent_articles"))
        end
        
        if marshal_load($redis.get("#{@category.name.downcase}_mostview_articles")).blank?
            @mostviews = @category.articles.active_source.
                        includes(:source, :categories, :states).
                        order("num_views DESC").
                        paginate(:page => params[:page], :per_page => 24) 
            $redis.set("#{@category.name.downcase}_mostview_articles", Marshal.dump(@mostviews))           
        else
            @mostviews = Marshal.load($redis.get("#{@category.name.downcase}_mostview_articles"))
        end
        
    end
  
    private
    
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                redirect_to root_path
            end
        end
        
        def set_category
            if marshal_load($redis.get("category_#{params[:id]}")).blank?
                @category = Category.friendly.find(params[:id])
                set_into_redis
            else
                get_from_redis
            end     
            if @category.blank?
                redirect_to root_path 
            end
        end

        def set_into_redis
            $redis.set("category_#{params[:id]}", marshal_dump(@category))
        end

        def get_from_redis
            @category = marshal_load($redis.get("category_#{params[:id]}")) 
        end
end