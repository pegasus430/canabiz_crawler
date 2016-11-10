class NewsHighTimes < ActiveJob::Base
    include SuckerPunch::Job
    
    
    def perform()
    	
    	logger.info "HighTimes background job is running"
        scrapeHighTimes()	
    end
    
    def scrapeHighTimes()
        
        
        require "json"
        require 'open-uri'
        
        #removed ##print u'Processing article: {}'.format(title)
        output = IO.popen(["python", "#{Rails.root}/app/scrapers/news_scrapper.py"]) #cmd,
        contents = JSON.parse(output.read)
        
        #call method:
        
        if contents["articles"] != nil
        	addArticles(contents["articles"])	
        end
        
        
        #puts contents["url"]
        #puts contents["articles"][1]["title"]
        #puts contents["articles"][1]["date"]
        ##puts contents["articles"][1]["image_url"]
        #puts contents["articles"][1]["url"]
        #puts contents["articles"][1]["text_plain"]
        
           	
    end
    
    def addArticles(articles)

        @random_category = Category.where(:name => 'Random')
        @categories = Category.where(:active => true)
        @states = State.all
        source = Source.find_by name: 'HighTimes'
        
        articles.each do |article|
        
	        #MATCH ARTICLE CATEGORIES BASED ON KEYWORDS IN CATEGORY ARRAYS
	        relateCategoriesSet = Set.new
	        @categories.each do |category|
	            if category.keywords.present?
	                category.keywords.split(',').each do |keyword|
	                    if  (article["title"] != nil && article["title"].include?(keyword))
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
	                    if  (article["title"] != nil && article["title"].include?(keyword))
	                        relateStatesSet.add(state.id)
	                    end
	                end
	            end
	        end
	        
	        #CREATE ARTICLE
	        #missing abstract right now
	        article = Article.create(:title => article["title"], :image => article["image_url"], :source_id => source.id, :date => DateTime.parse(article["date"]), :web_url => article["url"], :body => article["text_plain"].gsub(/\n/, '<br/><br/>'))
	        
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
	   
    end #end of add article method
end