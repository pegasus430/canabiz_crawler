class NewsCannabisCulture < ActiveJob::Base
    include SuckerPunch::Job
    
    def perform()
        logger.info "Cannabis Culture background job is running"
        scrapeCannabisCulture()

    end
    
    def scrapeCannabisCulture()
        #store image
        #https://github.com/savon40/Cannabiz-SecondAttempt/commit/f7e51bb4f5153f073d4ffeb8d888e78a463e63e2
        
        require "json"
        require 'open-uri'
        
        #leafly removed here
            #date_raw = article.xpath('(//div[@class="leafly-publish-date"])/text()')
            #date = None
            #if len(date_raw):
                #date_raw = date_raw[0]
                #date = datetime.strptime(date_raw.strip(), "%B %d, %Y")
        
        #removed ##print u'Processing article: {}'.format(title)   print u'Processing article: {}'.format(title)
        output = IO.popen(["python", "#{Rails.root}/app/scrappers/newsparser_cannabisculture.py"]) #cmd,
        contents = JSON.parse(output.read)
        
        #call method:
        
        if contents["articles"] != nil
        	addArticles(contents["articles"])	
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
	        

	        #if (article["image_url"] != nil)
	        
	        	#data = open(article["image_url"])
	        	#@image_stored = File.new(data)

	        	#CREATE ARTICLE
	        	#missing abstract right now
	        	puts "this is the image url: " + article["image_url"]
	        	
	        	if article["date"] != nil
	        		article = Article.create(:title => article["title"], :remote_image_url => article["image_url"], :source_id => source.id, :date => DateTime.parse(article["date"]), :web_url => article["url"], :body => article["text_plain"].gsub(/\n/, '<br/><br/>'))	
	        	else 
	        		article = Article.create(:title => article["title"], :remote_image_url => article["image_url"], :source_id => source.id, :date => DateTime.now, :web_url => article["url"], :body => article["text_plain"].gsub(/\n/, '<br/><br/>'))
	        	end
	        #else 
	    		#CREATE ARTICLE
	        	#missing abstract right now
	        #	article = Article.create(:title => article["title"], :source_id => source.id, :date => DateTime.parse(article["date"]), :web_url => article["url"], :body => article["text_plain"].gsub(/\n/, '<br/><br/>'))
	        #end
	        

	        
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