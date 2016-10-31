class PagesController < ApplicationController
    
    #before_action :require_admin, only: [:admin]
    
    def home
        @all_sources = Source.all
        @articles = Article.where('image IS NOT NULL').order("created_at DESC").limit(20)
        #Dispensary.order
        
        
        
        # news background jobs:
        #NewsMjBizDaily.perform_later()
        #NewsTheCannabist.perform_later()
        #NewsCannabisCulture.perform_later()
        
    end
    
    def homepage_ajax
        @home_articles = Article.where('image IS NOT NULL').order("RANDOM()").where(:source_id => params[:sources]).limit(20)
        
        if @home_articles
          render partial: "pages/article_layout"
        end
    end
    
    def admin
    end
    
    def search
        if params[:query].present? 
            @q = "%#{params[:query]}%"
            
            @articles = Article.where("source LIKE ? or title LIKE ? or abstract LIKE ?", @q, @q, @q)

        else 
            redirect_to root_path
        end
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
                flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end
end