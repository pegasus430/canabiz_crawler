class CannaLawBlogWorker
  include Sidekiq::Worker

    def perform()
    	
    	logger.info "Canna Law Blog background job is running"
        scrapeCannaLawBlog()	
    end
    
    def scrapeCannaLawBlog()
        
        require "json"
        require 'open-uri'
        
        begin
    		output = IO.popen(["python", "#{Rails.root}/app/scrapers/newsparser_cannalawblog.py"]) #cmd,
        	logger.info 'BEFORE THE CONTENTS:::'
        	contents = JSON.parse(output.read)
        	logger.info 'HERE ARE THE CONTENTS:::::'

        	if contents["articles"] != nil && contents["articles"].size > 0
        		logger.info 'IN ARTICLE IF STATEMENT:::::'
	        	addArticles(contents["articles"])	
	        else 
	        	ScraperError.email('CannaLawBlog News', 'No Articles were returned').deliver	
	        end
        
        rescue => ex
        	ScraperError.email('CannaLawBlog News', ex.message).deliver
		end
           	
    end
    
    def addArticles(articles)

        @random_category = Category.where(:name => 'Random')
        @categories = Category.where(:active => true)
        @states = State.all
        source = Source.find_by name: 'Canna Law Blog'
        
        logger.info 'GLOBAL VARIABLES DECLARED:::::'
        logger.info source
        
        articles.each do |article|
        	
        	logger.info 'IN ARTICLE LOOP:::::'
	        #MATCH ARTICLE CATEGORIES BASED ON KEYWORDS IN CATEGORY ARRAYS
	        relateCategoriesSet = Set.new
	        @categories.each do |category|
	            if category.keywords.present?
	                category.keywords.split(',').each do |keyword|
	                    if  (article["title"] != nil && article["title"].downcase.include?(keyword.downcase))
	                        relateCategoriesSet.add(category.id)
	                        break
	                    end
	                end
	            end
	        end
	        
	        logger.info 'AFTER CATEGORY MATCHING:'
	        
	        #MATCH ARTICLE STATES
	        relateStatesSet = Set.new
	        @states.each do |state|
	            if state.keywords.present?
	                state.keywords.split(',').each do |keyword|
	                    #not using downcase cause i dont want to match state abbreviations that aren't capitalized
	                    if  (keyword.length == 2 && article["title"] != nil && article["title"].split(" ").include?(keyword))
	                        relateStatesSet.add(state.id)
	                        break
	                    elsif (keyword.length > 2 && article["title"] != nil && article["title"].include?(keyword))
	                    	relateStatesSet.add(state.id)
	                        break
	                    elsif (keyword.length > 2 && article["text_html"] != nil && article["text_html"].include?(keyword))
	                    	relateStatesSet.add(state.id)
	                    	break
	                    end
	                end
	            end
	        end
	        
	        logger.info 'AFTER STATE MATCHING:'
	        


        	#CREATE ARTICLE
        	#missing abstract right now
        	
        	if article["date"] != nil
        		article = Article.create(:title => article["title"], :remote_image_url => article["image_url"], :source_id => source.id, :date => DateTime.parse(article["date"]), :web_url => article["url"], :body => article["text_html"])	#.gsub(/\n/, '<br/><br/>')
        	else 
        		article = Article.create(:title => article["title"], :remote_image_url => article["image_url"], :source_id => source.id, :date => DateTime.now, :web_url => article["url"], :body => article["text_html"]) #.gsub(/\n/, '<br/><br/>')
        	end
        	
        	logger.info 'ARTICLE CREATED!!!!'

	        
	        #CREATE ARTICLE CATEGORIES
	        #If no category, set category to random
	        if relateCategoriesSet.empty?
	           relateCategoriesSet.add(@random_category[0].id) 
	        end
	        
	        relateCategoriesSet.each do |setObject|
	            ArticleCategory.create(:category_id => setObject, :article_id => article.id)
	        end
	        
	        logger.info 'ARTICLE CATEGORIES CREATED:'
	        
	        #CREATE ARTICLE STATES
	        relateStatesSet.each do |setObject|
	            ArticleState.create(:state_id => setObject, :article_id => article.id)
	        end 
	        
	        logger.info 'ARTICLE STATES CREATED'
	        
	   end #end of article loop
	   
	   #update last run date of scraper
	   source.update_attribute(:last_run, DateTime.now)
	   
    end #end of add article method
end
