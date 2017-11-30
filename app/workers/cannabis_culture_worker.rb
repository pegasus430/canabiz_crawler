class CannabisCultureWorker
  include Sidekiq::Worker

def perform()
        logger.info "Cannabis Culture background job is running"
        scrapeCannabisCulture()

    end
    
    def scrapeCannabisCulture()
        
        require "json"
        require 'open-uri'
        
        begin
        	output = IO.popen(["python", "#{Rails.root}/app/scrapers/newsparser_cannabisculture.py"]) #cmd,
        	contents = JSON.parse(output.read)
        	if contents["articles"] != nil && contents["articles"].size > 0
	        	addArticles(contents["articles"])	
	        else 
	        	ScraperError.email('CannabisCulture News', 'No Articles were returned').deliver_now	
	        end
        
        rescue => ex
        	ScraperError.email('CannabisCulture News', ex.message).deliver_now
		end
    end
    
    def addArticles(articles)

        @random_category = Category.where(:name => 'Random')
        @categories = Category.where(:active => true)
        @states = State.all
        source = Source.find_by name: 'Cannabis Culture'
        
        articles.each do |article|
        
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
	        
	        #CREATE ARTICLE
	        date = article["date"] ? DateTime.parse(article["date"]) : DateTime.now
        	article = Article.new(
				:title => article["title"], 
				:remote_image_url => article["image_url"],
				:source_id => source.id, 
				:date => date, 
				:web_url => article["url"], 
				:body => article["text_html"]
        	)
        	
        	unless article.save
        		ScraperError.email('Cannabis Culture News', 
        			"Article Save Error: #{article.errors.messages}").deliver_now
        	end
	        

	        
	        #CREATE ARTICLE CATEGORIES
	        #If no category, set category to random
	        if relateCategoriesSet.empty?
	           relateCategoriesSet.add(@random_category[0].id) 
	        end
	        
	        relateCategoriesSet.each do |setObject|
	            ArticleCategory.create(:category_id => setObject, :article_id => article.id)
	        end
	        
	        #CREATE ARTICLE STATES
	        relateStatesSet.each do |setObject|
	            ArticleState.create(:state_id => setObject, :article_id => article.id)
	        end 
	        
	   end #end of article loop
	   
	   #update last run date of scraper
	   source.update_attribute(:last_run, DateTime.now)
	   
    end #end of add article method
end
