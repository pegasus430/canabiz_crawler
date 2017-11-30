class NewsScraperHelper
	
	attr_reader :articles, :source_name
	
	def initialize(articles, source_name)
		@articles = articles
		@source_name = source_name
	end
	
	def addArticles
        @categories = Category.active.news
        @random_category = @categories.where(:name => 'Random')
        @states = State.all
        source = Source.find_by name: @source_name
        
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
        	image_url = ''
        	
        	if @source_name == 'Canna Law Blog'
        		if article["image_url"].present?
        			image_url = article["image_url"].gsub(/\A(\/\/)/, '') 
					image_url = "https://#{image_url}"
        		end
        		
        	else 
        		image_url = article["image_url"]
        	end

        	date = article["date"] ? DateTime.parse(article["date"]) : DateTime.now
        	article = Article.new(
				:title => article["title"], 
				:remote_image_url => image_url,
				:source_id => source.id, 
				:date => date, 
				:web_url => article["url"], 
				:body => article["text_html"]
        	)
        	unless article.save
        		puts "Article Save Error: #{article.errors.messages}"
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
	
	end #end of article method
end