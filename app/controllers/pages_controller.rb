class PagesController < ApplicationController
    
    before_action :require_admin, only: [:admin]
    
    def home
            
        #only showing all articles on homepage now
        @recents = Article.order("created_at DESC").paginate(:page => params[:page], :per_page => 24)
        @mostviews = Article.order("num_views DESC").paginate(:page => params[:page], :per_page => 24)
        
        respond_to do |format|
          format.html
          format.js # add this line for your js template
        end
        
        #removed from marijuana stocks line 9 #import urllib3
        NewsCannaLawBlog.perform_later()

        # news background jobs:
        if Rails.env.production?
            NewsDopeMagazine.perform_later()
            NewsMarijuanaStocks.perform_later()
            NewsLeafly.perform_later()
            NewsTheCannabist.perform_later()
            NewsMarijuana.perform_later()
            NewsCannabisCulture.perform_later()
            NewsCannaLawBlog.perform_later()
            NewsMjBizDaily.perform_later()
            NewsHighTimes.perform_later()
            NewsFourTwentyTimes.perform_later()
        end
        
    end 
    
    def not_in_use
       
       #homepage only showing user articles
        if current_user != nil
            
            @recents = Article.order("created_at DESC").paginate(:page => params[:page], :per_page => 24)
            @mostviews = Article.order("num_views DESC").paginate(:page => params[:page], :per_page => 24)
            
            if current_user.sources.any?
                 @recents = @recents.where(source_id: current_user.sources)
                 @mostviews = @mostviews.where(source_id: current_user.sources)
            end
            
            if current_user.states.any?
                #add a where clause to only be user states
                state_ids = current_user.states.pluck(:id)
                article_ids = ArticleState.where(state_id: state_ids).pluck(:article_id)
                @recents = @recents.where(id: article_ids)
                @mostviews = @mostviews.where(id: article_ids)
                
            end
            
            if current_user.categories.any?
               #add a where clause to only be user categories
                category_ids = current_user.categories.pluck(:id)
                article_ids = ArticleCategory.where(category_id: category_ids).pluck(:article_id)
                @recents = @recents.where(id: article_ids)
                @mostviews = @mostviews.where(id: article_ids)
            end
            
        else 
            @recents = Article.order("created_at DESC").paginate(:page => params[:page], :per_page => 24)
            @mostviews = Article.order("num_views DESC").paginate(:page => params[:page], :per_page => 24)
        end
    end
    
    def admin
    end
    
    def search
        if params[:query].present? 
            @query = "%#{params[:query]}%"
            @searchQuery = params[:query]
            
            if Rails.env.production?
                @recents = Article.where("title iLIKE ANY (array[?]) or body  iLIKE ANY (array[?]) ", @query.split,@query.split).order("created_at DESC").page(params[:page]).per_page(24)
                @mostviews = Article.where("title iLIKE ANY (array[?]) or body  iLIKE ANY (array[?]) ", @query.split, @query.split).order("num_views DESC").page(params[:page]).per_page(24)
                
            else 
                @recents = Article.where("title LIKE ? or body LIKE ?", @query, @query).order("created_at DESC").paginate(:page => params[:page], :per_page => 24) 
                @mostviews = Article.where("title LIKE ? or body LIKE ?", @query, @query).order("created_at DESC").paginate(:page => params[:page], :per_page => 24) 
            end
            
            
            
            #@mostviews = Article.where("title LIKE ? or body LIKE ?", @query, @query)
                                        

        else 
            redirect_to root_path
        end
    end
    
    #user signs up to the weekly digest
    def save_email
        if params[:email].present?
            #make sure email does not exist
            if DigestEmail.where(email: params[:email]).any?
               flash[:danger] = 'Email already subscribed to Roll Up'
               redirect_to root_path
            else
                DigestEmail.create(email: params[:email], active: true)
                #flash.now[:message] = 'Thank you for signing up to the Weekly Roll Up!'
                flash[:success] = 'Thank you for signing up to the Weekly Roll Up!'
                redirect_to root_path
            end
        else
            flash[:danger] = 'No Email Provided'
            redirect_to root_path
        end
    end
    
    #unsubscribe from weekly digest
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
        else 
            redirect_to root_path
        end
        
        
    end
    
    def submit_feedback_form
        Feedback.email(params[:firstTime], params[:primaryReason], params[:findEverything], 
                        params[:reasonDidntFind], params[:easyInformation], params[:likelihood],
                        params[:suggestion]).deliver 
       
        flash[:success] = 'Thank you for submitting Feedback!'
        redirect_to root_path
    end
    
    
    # Exchange your oauth_token and oauth_token_secret for an AccessToken instance.
    #def prepare_access_token(oauth_token, oauth_token_secret)

    #    consumer = OAuth::Consumer.new("PeKIPXsMPl80fKm6SipbqrRVL", "EzcwBZ1lBd8RlnhbuDyxt3URqPyhrBpDq00Z6n4btsnaPF7VpO", 
    #                                    { :site => "https://api.twitter.com", :scheme => :header })
         
        # now create the access token object from passed values
    #    token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
    #    access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
     
    #    return access_token
    #end
    #helper_method :prepare_access_token
    
    private
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                redirect_to root_path
            end
        end
end