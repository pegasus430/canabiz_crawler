class NewsFourTwentyTimes < ActiveJob::Base
    include SuckerPunch::Job
    
    
    def perform()
    	
    	logger.info "420 Times background job is running"
        scrape420()	
    end
    
    def scrape420()
        
        require "json"
        require 'open-uri'
        
        begin
	        output = IO.popen(["python", "#{Rails.root}/app/scrapers/newsparser_the420times.py"]) #cmd,
	        contents = JSON.parse(output.read)
	        
			#call method
	        if contents["articles"].present?
	        	NewsScraperHelper.new(contents["articles"], 'The 420 Times').addArticles
	        else 
	        	ScraperError.email('The 420 Times News', 'No Articles were returned').deliver_now	
	        end
	    rescue => ex
        	ScraperError.email('The 420 Times News', ex.message).deliver_now
		end
    end
end