class NewsCannabisCulture < ActiveJob::Base
    include SuckerPunch::Job
    
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
	        
			#call method
	        if contents["articles"].present?
	        	NewsScraperHelper.new(contents["articles"], 'Cannabis Culture').addArticles
	        else 
	        	ScraperError.email('CannabisCulture News', 'No Articles were returned').deliver_now	
	        end
	    rescue => ex
        	ScraperError.email('CannabisCulture News', ex.message).deliver_now
		end
    end
end