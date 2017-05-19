#delete all article category, article state records 

class SetArticlesJob < ActiveJob::Base
	
	def perform()
        logger.info "Set Article Show"
        setArticleCategories()
    end 
    
    def setArticleCategories()
		#delete existing
		ArticleCategory.destroy_all
		ArticleState.destroy_all
		
		#query for matching records
		@random_category = Category.where(:name => 'Random')
        @categories = Category.where(:active => true)
        @states = State.all
        
        Article.where("title IS NOT NULL").each do |article|
        	
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
	                    if  (article["title"] != nil && article["title"].include?(keyword))
	                        relateStatesSet.add(state.id)
	                        break
	                    elsif (keyword.length > 2 && article["text_html"] != nil && article["text_html"].include?(keyword))
	                    	relateStatesSet.add(state.id)
	                    	break
	                    end
	                end
	            end
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
        
    end #end of setArticleCategories() method
end