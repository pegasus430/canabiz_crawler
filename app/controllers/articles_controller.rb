class ArticlesController < ApplicationController
    before_action :set_article, only: [:edit, :update, :destroy, :show, :tweet]
    before_action :require_admin, only: [:edit, :update, :destroy, :admin, :digest, :tweet]

    #--------ADMIN PAGE-------------------------
    def admin
        @articles = Article.order(sort_column + " " + sort_direction).paginate(page: params[:page], per_page: 100)
    
        #for csv downloader
        respond_to do |format|
            format.html
            format.csv {render text: @articles.to_csv }
        end
    end
    
    #method is used for csv file upload
    def import
        Article.import(params[:file])
        flash[:success] = 'Articles were successfully imported'
        redirect_to article_admin_path 
    end
    
    def search
        @q = "%#{params[:query]}%"
        @articles = Article.where("title LIKE ? or abstract LIKE ?", @q, @q).order(sort_column + " " + 
                                    sort_direction).paginate(page: params[:page], per_page: 50)
        render 'admin'
    end
    
    def tweet
        #not on admin page but admin functionality
    end
    
    def send_tweet
        
       	require 'rubygems'
		require 'oauth'
		require 'json'
		
		if params[:tweet_body].present?

    		consumer_key = OAuth::Consumer.new(
    		    "PeKIPXsMPl80fKm6SipbqrRVL",
    		    "EzcwBZ1lBd8RlnhbuDyxt3URqPyhrBpDq00Z6n4btsnaPF7VpO")
    		access_token = OAuth::Token.new(
    		    "418377285-HfXt8G0KxvBhNXQJRnnysTvt7yGAM0jWyfaIKSIU",
    		    "3QF4wvh1ESmSuKqWztD8LibyVJHhYNMcc93YlTWdrPqez")
    		
    		# Note that the type of request has changed to POST.
    		# The request parameters have also moved to the body
    		# of the request instead of being put in the URL.
    		baseurl = "https://api.twitter.com"
    		path    = "/1.1/statuses/update.json"
    		address = URI("#{baseurl}#{path}")
    		request = Net::HTTP::Post.new address.request_uri
    		request.set_form_data(
    		  "status" => params[:tweet_body],
    		)
    		
    		# Set up HTTP.
    		http             = Net::HTTP.new address.host, address.port
    		http.use_ssl     = true
    		http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    		
    		# Issue the request.
    		request.oauth! http, consumer_key, access_token
    		http.start
    		response = http.request request
    		
    		if response.code == '200' then
    		  flash[:success] = 'Tweet Sent'
    		else
    		  flash[:danger] = 'No Tweet Sent'
    		end
		
            
            redirect_to root_path
        else
            flash[:danger] = 'No Tweet Sent'
            redirect_to root_path
        end
    end
    
    def digest
        #not on admin page but admin functionality
    end
    
    #--------ADMIN PAGE-------------------------
    
    def index
        @top_articles = Article.where('image IS NOT NULL').limit(4)
        @categories = Category.order("RANDOM()").limit(4) #randomize the categories that are returned
    end

    #-----------------------------------
    def new
      @article = Article.new
    end
    def create
      @article = Article.new(article_params)
      if @article.save
         flash[:success] = 'Article was successfully created'
         redirect_to article_admin_path
      else 
         render 'new'
      end
    end 
    #-----------------------------------
    
    def show
        #related articles
        if @article.categories.present?
            @related_articles = Article.all.order("RANDOM()").limit(3) 
        elsif @article.states.present?
            @related_articles = Article.all.order("RANDOM()").limit(3)  
        else
            @related_articles = Article.all.order("RANDOM()").limit(3)
        end
        
        #same source articles
        @same_source_articles = Article.where(source_id: @article.source).limit(3)
        
        #add view to article for sorting
        @article.increment(:num_views, by = 1)
        @article.save
        
        #add userView record
        if current_user
            #the table isn't created yet
        end
    end
    
    #-----------------------------------
    def edit
    end   
    def update
        if @article.update(article_params)
            flash[:success] = 'Article was successfully updated'
            redirect_to article_admin_path
        else 
            render 'edit'
        end
    end 
    #-----------------------------------
   
    def destroy
        @article.destroy
        flash[:success] = 'Article was successfully deleted'
        redirect_to article_admin_path
    end 
   
    def destroy_multiple
      Article.destroy(params[:articles])
      flash[:success] = 'Articles were successfully deleted'
      redirect_to article_admin_path        
    end   
    
    private 
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                flash[:danger] = 'Only administrators can visit that page'
                redirect_to root_path
            end
        end
        
        def set_article
            @article = Article.find(params[:id])
            if @article.blank?
                flash[:danger] = 'The page you are looking for does not exist'
                redirect_to root_path 
            end
        end
        def article_params
            params.require(:article).permit(:title, :abstract, :body, :date, :image, :source_id, :include_in_digest, state_ids: [], category_ids: [])
        end
      
        def sort_column
            params[:sort] || "date"
        end
        def sort_direction
            params[:direction] || 'desc'
        end
          
end