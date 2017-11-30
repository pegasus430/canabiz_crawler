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
	        contents = JSON.parse(output.read)
	        
	        #call method:
	        if contents["articles"] != nil
	        	NewsScraperHelper.new(contents["articles"], 'Canna Law Blog').addArticles
	        else 
	        	ScraperError.email('CannaLawBlog News', 'No Articles were returned').deliver_now	
	        end
        rescue => ex
        	ScraperError.email('CannaLawBlog News', ex.message).deliver_now
		end
           	
    end
end
