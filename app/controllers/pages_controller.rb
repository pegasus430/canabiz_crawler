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
        
        #NewsTheCannabist.perform_later()
        #NewsLeafly.perform_later()
        NewsDopeMagazine.perform_later()
        
        #removed from marijuana stocks line 9 #import urllib3
        if Rails.env.production?
            Source.where("name IS NOT NULL").each do |source|
    
                if source.name == 'Marijuana.com' && (source.last_run + 2.hours) <= DateTime.now
                    NewsDopeMagazine.perform_later()
                end
                if source.name == 'Marijuana Stocks' && (source.last_run + 2.hours) <= DateTime.now
                    NewsMarijuanaStocks.perform_later()
                end
                if source.name == 'Leafly' && (source.last_run + 2.hours) <= DateTime.now
                    NewsLeafly.perform_later()
                end
                if source.name == 'The Cannabist' && (source.last_run + 2.hours) <= DateTime.now
                    NewsTheCannabist.perform_later()
                end
                if source.name == 'Marijuana.com' && (source.last_run + 2.hours) <= DateTime.now
                    NewsMarijuana.perform_later()
                end
                if source.name == 'Cannabis Culture' && (source.last_run + 2.hours) <= DateTime.now
                    NewsCannabisCulture.perform_later()
                end
                if source.name == 'Canna Law Blog' && (source.last_run + 2.hours) <= DateTime.now
                    NewsCannaLawBlog.perform_later()
                end
                if source.name == 'MJ Biz Daily' && (source.last_run + 2.hours) <= DateTime.now
                    NewsMjBizDaily.perform_later()
                end
                if source.name == 'HighTimes' && (source.last_run + 2.hours) <= DateTime.now
                    NewsHighTimes.perform_later()
                end
                if source.name == 'The 420 Times' && (source.last_run + 2.hours) <= DateTime.now
                    NewsFourTwentyTimes.perform_later()
                end
                
            end
        end
    end 
    
    def scrapersetup
       if Rails.env.production?
            Source.all do |source|
                if source.name == 'Dope Maganize' && source.last_run + (2/24.0) <= DateTime.now
                    NewsDopeMagazine.perform_later()
                end
                
            end
            
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
    
    def sitemap
        @sources = Source.all.order("name ASC")
        @categories = Category.all.order("name ASC")
        @states = State.all.order("name ASC")
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