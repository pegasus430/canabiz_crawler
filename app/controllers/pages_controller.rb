class PagesController < ApplicationController
    
    before_action :require_admin, only: [:admin]
    
    def home
        
        #sort by the option selected by user
        if params[:option] != nil
            @sort_option = SortOption.find(params[:option])
            
            #add a click to the sort option
            @sort_option.increment(:num_clicks, by = 1)
            @sort_option.save
            
            @articles = Article.paginate(page: params[:page], per_page: 24).order(@sort_option.query + " " + @sort_option.direction)
        else 
            @articles = Article.paginate(page: params[:page], per_page: 24).order("created_at DESC")
        end
        
        respond_to do |format|
          format.html
          format.js
        end
        
        # news background jobs:
        #NewsHighTimes.perform_later()
        #NewsMarijuana.perform_later()
        
        #NewsMjBizDaily.perform_later()
        NewsTheCannabist.perform_later()
        #NewsCannabisCulture.perform_later()
        
    end
    
    def admin
    end
    
    def search
        if params[:query].present? 
            @q = "%#{params[:query]}%"
            
            @articles = Article.where("title LIKE ? or abstract LIKE ?", @q, @q)

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
        
        flash[:danger] = 'Sorry, There was an error with the form Submission'
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