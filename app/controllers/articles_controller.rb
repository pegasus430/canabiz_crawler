class ArticlesController < ApplicationController
    before_action :set_article, only: [:edit, :update, :destroy, :show]
    before_action :require_admin, except: [:index, :show]
    skip_before_action :verify_authenticity_token #for saving article via ajax
    
    #method saves an external click of an article link (goes to external page)
    def save_visit

        if params[:id].present?
            
           #query for article
           @article = Article.find(params[:id])
           @article.increment(:external_visits, by = 1)
           @article.save
        
           @source = @article.source
           @source.increment(:external_article_visits, by = 1)
           @source.save

        else
            redirect_to root_path     
        end
    end
    
    #user saves an article for later
    def user_article_save

        if !logged_in?
            redirect_to login_path
        end 
        if params[:id].present?
            
            #if a user has already saved or viewed this article, just use the same record
            if UserArticle.where(:article_id => params[:id], :user_id => current_user.id).any?
                @current_user_article = UserArticle.where(:article_id => params[:id], :user_id => current_user.id)
                if (@current_user_article[0].saved == true) 
                    @current_user_article[0].update_attribute :saved, false
                else 
                    @current_user_article[0].update_attribute :saved, true
                end
            else 
                UserArticle.create(user_id: current_user.id, article_id: params[:id], saved: true)
            end

            
        end
    end     

    

    
    def update_states_categories
    end
    
    def update_article_tags
        SetArticlesJob.perform_later() 
        flash[:success] = 'Articles will continue to update in the background'
        redirect_to admin_path
    end
        
    
    #--------ADMIN PAGE-------------------------
    
    def index
        #only showing articles for active sources 
        @recents = Article.active_source.order("created_at DESC").paginate(:page => params[:page], :per_page => 24)
        @mostviews = Article.active_source.where("created_at >= ?", 1.month.ago.utc).
                        order("num_views DESC").
                        paginate(:page => params[:page], :per_page => 24)
        
        respond_to do |format|
          format.html
          format.js # add this line for your js template
        end
    end
    #-----------------------------------
    
    def show
        
        # go back if source not active
        if @article.source.active == false
            redirect_to root_path
        end
        
        #we will now show some top products instead of related articles
        @top_products = Product.featured.joins(:dispensary_source_products, :average_prices).
                        group("products.id").
                        having("count(dispensary_source_products.id)>4").
                        having("count(average_prices.id)>0").
                        includes(:vendors, :category).
                        order("RANDOM()").limit(3)

        #SAME SOURCE ARTICLES
        @same_source_articles = Article.where(source_id: @article.source).order("created_at DESC").
                                    limit(3).where.not(id: @article.id).
                                    includes(:source, :states ,:categories)
        
        #add view to article for sorting
        @article.increment(:num_views, by = 1)
        @article.save
    end
    
    
    
    private 
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                redirect_to root_path
            end
        end
        
        def set_article
            if marshal_load($redis.get("article_#{params[:id]}")).blank?
                @article = Article.friendly.find(params[:id])
                set_into_redis
            else
                get_from_redis
            end     
            if @article.blank?
                redirect_to root_path 
            end
        end

        def set_into_redis
            $redis.set("article_#{params[:id]}", marshal_dump(@article))
        end

        def get_from_redis
            @article = marshal_load($redis.get("article_#{params[:id]}")) 
        end
end