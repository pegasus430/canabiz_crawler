class PagesController < ApplicationController
    
    before_action :require_admin, only: [:admin]
    
    def home
        if current_user != nil
            
            @articles = Article.order("created_at DESC").page(params[:page]).per_page(24)
            @articles_viewed = Article.order("num_views DESC").page(params[:page]).per_page(24)
            
            if current_user.sources.any?
                 @articles = @articles.where(source_id: current_user.sources)
                 @articles_viewed = @articles_viewed.where(source_id: current_user.sources)
            end
            
            if current_user.states.any?
                #add a where clause to only be user states
                state_ids = current_user.states.pluck(:id)
                article_ids = ArticleState.where(state_id: state_ids).pluck(:article_id)
                @articles = @articles.where(id: article_ids)
                @articles_viewed = @articles_viewed.where(id: article_ids)
                
            end
            
            if current_user.categories.any?
               #add a where clause to only be user categories
                category_ids = current_user.categories.pluck(:id)
                article_ids = ArticleCategory.where(category_id: category_ids).pluck(:article_id)
                @articles = @articles.where(id: article_ids)
                @articles_viewed = @articles_viewed.where(id: article_ids)
            end
            
        else 
            @articles = Article.order("created_at DESC").page(params[:page]).per_page(24)
            @articles_viewed = Article.order("num_views DESC").page(params[:page]).per_page(24)
        end    
        
        respond_to do |format|
          format.html
          format.js # add this line for your js template
        end
        
        
        # news background jobs:
        if Rails.env.production?
            NewsMarijuanaStocks.perform_later()
            NewsTheCannabist.perform_later()
            NewsLeafly.perform_later()
            NewsMarijuana.perform_later()
            NewsCannabisCulture.perform_later()
            NewsCannaLawBlog.perform_later()
            NewsMjBizDaily.perform_later()
            NewsHighTimes.perform_later()
            NewsDopeMagazine.perform_later()
            NewsFourTwentyTimes.perform_later()
            
        end
        
    end 
    
    def other
        #@articles = Article.order("created_at DESC").page(params[:page]).per_page(24)
        
        #@articles_viewed = Article.order("num_clicks DESC").page(params[:page]).per_page(24)
        
        #sort by the option selected by user
        if params[:option] != nil
            @sort_option = SortOption.find(params[:option])
            
            if @sort_option != nil
                #add a click to the sort option
                @sort_option.increment(:num_clicks, by = 1)
                @sort_option.save
                
                @articles = Article.order(@sort_option.query + " " + @sort_option.direction).page(params[:page]).per_page(24)
            else 
                @articles = Article.order("created_at DESC").page(params[:page]).per_page(24)    
            end
        else

        end
        
        respond_to do |format|
          format.html
          format.js
        end
        

        
    end
    
    def admin
    end
    
    def search
        if params[:query].present? 
            @query = "%#{params[:query]}%"
            
            @articles = Article.where("title LIKE ? or abstract LIKE ?", @query, @query).page(params[:page]).per_page(24)
            @articles_viewed = Article.where("title LIKE ? or abstract LIKE ?", @query, @query).page(params[:page]).per_page(24)
        else 
            redirect_to root_path
        end
    end
    
    def save_email
        if params[:email].present?
            DigestEmail.create(email: params[:email], active: true)
            flash[:success] = 'Thank you for signing up to the Weekly Roll Up!'
            redirect_to root_path
        else
            flash[:danger] = 'No Email Provided'
            redirect_to root_path
        end
    end
    
    def unsubscribe
        if params[:id].present?
        
            if params[:id].split('d').count == 2 && params[:id].split('d')[1].split('G').count == 2 
            	
            	@actual_id = params[:id].split('d')[1].split('G')[0]
            	
            	@digest = DigestEmail.find(@actual_id)
                @digest.active = false
                @digest.save
            
            else
                redirect_to root_path
            end
        else 
            redirect_to root_path   
        end
    end
    
    def submit_contact_form
        if params[:name] != nil && params[:email] != nil && params[:message] != nil
           
           ContactUs.email(params[:name], params[:email], params[:message]).deliver 
           
           flash[:success] = 'Thanks for your message! We look forward to responding soon'
           redirect_to root_path
        end
        
        redirect_to root_path
    end
    
    
    # Exchange your oauth_token and oauth_token_secret for an AccessToken instance.
    def prepare_access_token(oauth_token, oauth_token_secret)

        consumer = OAuth::Consumer.new("PeKIPXsMPl80fKm6SipbqrRVL", "EzcwBZ1lBd8RlnhbuDyxt3URqPyhrBpDq00Z6n4btsnaPF7VpO", 
                                        { :site => "https://api.twitter.com", :scheme => :header })
         
        # now create the access token object from passed values
        token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
        access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
     
        return access_token
    end
    helper_method :prepare_access_token
    
    private
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                redirect_to root_path
            end
        end
end