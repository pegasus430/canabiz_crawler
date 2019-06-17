class SourcesController < ApplicationController
    
    before_action :set_source, only: [:edit, :update, :destroy, :show] #
    before_action :require_admin, except: [:show]
    
    def show
        if @source.active
            
            if marshal_load($redis.get("#{@source.name.downcase}_recent_articles")).blank?
                @recents = @source.articles.includes(:source, :categories, :states).
                        order("created_at DESC").page(params[:page]).per_page(24)
                $redis.set("#{@source.name.downcase}_recent_articles", Marshal.dump(@recents))           
            else
                @recents = Marshal.load($redis.get("#{@source.name.downcase}_recent_articles"))
            end
            
            # if marshal_load($redis.get("#{@source.name.downcase}_mostview_articles")).blank?
            #     @mostviews = @source.articles.includes(:source, :categories, :states).
            #             order("num_views DESC").page(params[:page]).per_page(24)
            #     $redis.set("#{@source.name.downcase}_mostview_articles", Marshal.dump(@mostviews))           
            # else
            #     @mostviews = Marshal.load($redis.get("#{@category.name.downcase}_mostview_articles"))
            # end
        
        else
            redirect_to root_path
        end
    end
  
    private
        
        def set_source
            if marshal_load($redis.get("source_#{params[:id]}")).blank?
                @source = Source.friendly.find(params[:id])
                set_into_redis
            else
                get_from_redis
            end     
            if @source.blank?
                redirect_to root_path 
            end
        end

        def set_into_redis
            $redis.set("source_#{params[:id]}", marshal_dump(@source))
        end

        def get_from_redis
            @source = marshal_load($redis.get("source_#{params[:id]}")) 
        end
end