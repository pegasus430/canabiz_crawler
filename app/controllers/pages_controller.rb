class PagesController < ApplicationController
    
    before_action :require_admin, only: [:admin]
    
    def home
        
        #test scraper
        ProductHeadset.perform_later('washington')
        
        #dont display nav search
        @nav_search = false
        
        #ARTICLES --  
        @recent_articles = State.where(name: 'Washington').first.articles.active_source.
                            order("created_at DESC").
                            includes(:states, :source, :categories).limit(16)

        #trending news - we should have num_views created this past week - not of all time - will do when moving live
        if Rails.env.production?
            @trending_articles = Article.active_source.
                        where("created_at >= ?", 1.week.ago.utc).order("num_views DESC").limit(10)
        else
            @trending_articles = Article.active_source.order("num_views DESC").
                                    includes(:states, :source, :categories).
                                    limit(10)
        end

        #PRODUCTS
        if @site_visitor_state != nil && @site_visitor_state.product_state
            
            if Rails.env.production? 
                @top_products = Product.featured.joins(:dispensary_source_products).group("products.id").having("count(dispensary_source_products.id)>4").
                                    includes(:vendors, :category, :average_prices).
                                    order("RANDOM()").limit(10)
            else
                @top_products = Product.featured.includes(:vendors, :category, :average_prices).
                                    order("RANDOM()").limit(10)
            end
            #not showing distance anymore
            #includes(:dispensary_sources, :vendors, :category, :average_prices, :dispensary_sources => :dispensary).
            #                            where(:dispensary_sources => {state_id: @site_visitor_state.id})
        
            #price range and distance
            #result = ProductHelper.new(@top_products, @site_visitor_ip).findProductsPriceAndDistance
            #@product_to_distance, @product_to_closest_disp = result[0], result[1]
        else 
            #Project.joins(:vacancies).group("projects.id").having("count(vacancies.id)>0")
            @top_products = Product.featured.joins(:dispensary_source_products).group("products.id").having("count(dispensary_source_products.id)>4").
                                    includes(:vendors, :category, :average_prices).
                                    order("RANDOM()").limit(10)
        end
        
        
    end 
    
    def admin
    end

    def search
        
        #allowing search for product and news
        if params[:query].present? 
            query = "%#{params[:query].downcase.strip}%"
            #query_no_sc = "%#{params[:query].downcase.strip.gsub!(/[^0-9A-Za-z]/, '')}%"
            @searchQuery = params[:query].strip
            #PRODUCTS
            @product_results = Product.featured.includes(:vendors, :dispensary_sources, :category).
                        where("LOWER(products.name) LIKE ? or LOWER(products.alternate_names) LIKE ?", query, query)
            
            @product_results_two = Product.featured.includes(:vendors, :dispensary_sources, :category).
                        where("LOWER(products.is_dom) LIKE ? or LOWER(categories.name) LIKE ? or LOWER(vendors.name) LIKE ? or LOWER(dispensary_sources.name) LIKE ? or LOWER(dispensary_sources.location) LIKE ? or LOWER(products.description) LIKE ?", 
                                query, query, query, query, query, query).
                        references(:vendors, :dispensary_sources, :categories)
                        
            @product_results = @product_results | @product_results_two
            
            @product_results = @product_results.paginate(page: params[:page], per_page: 16)
            
                            
            #result = ProductHelper.new(@product_results, @site_visitor_ip).findProductsPriceAndDistance
            #    @product_to_distance, @product_to_closest_disp = result[0], result[1]
            
            #NEWS
            if Rails.env.production?
                @article_results = Article.active_source.
                                where("title iLIKE ANY (array[?]) or body iLIKE ANY (array[?]) ", query.split,query.split).
                                includes(:source, :categories, :states).
                                order("created_at DESC").page(params[:page]).per_page(24)
            else 
                @article_results = Article.active_source.
                                where("title LIKE ? or body LIKE ?", query, query).
                                includes(:source, :categories, :states).
                                order("created_at DESC").paginate(:page => params[:page], :per_page => 24)
            end

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
        #need to update sitemap
    end
    
    private
        def require_admin
            if !logged_in? || (logged_in? and !current_user.admin?)
                redirect_to root_path
            end
        end
end