class NewsMarijuana < ActiveJob::Base
    include SuckerPunch::Job
    
    def perform()
    	logger.info "Marijuana background job is running"
        scrapMarijuana()	
    end
    
    def scrapMarijuana()
 
        require "json"
        require 'open-uri'

		begin
	        output = IO.popen(["python", "#{Rails.root}/app/scrapers/newsparser_marijuana.py"]) #cmd,
	        contents = JSON.parse(output.read)
	        
	        #call method:
	        if contents["articles"].present?
	        	NewsScraperHelper.new(contents["articles"], 'Marijuana.com').addArticles
	        else 
	        	ScraperError.email('Marijuana.com News', 'No Articles were returned').deliver_now	
	        end 	
	    rescue => ex
        	ScraperError.email('Marijuana.com News', ex.message).deliver_now
		end
    end
end