class HighTimesWorker
    include Sidekiq::Worker

    def perform()
    	
    	logger.info "HighTimes background job is running"
        scrapeHighTimes()	
    end
    
    def scrapeHighTimes()
        
        require "json"
        require 'open-uri'
        
        begin
	        output = IO.popen(["python", "#{Rails.root}/app/scrapers/newsparser_hightimes.py"]) #cmd,
	        contents = JSON.parse(output.read)
	        
	        #call method
	        if contents["articles"].present?
	        	NewsScraperHelper.new(contents["articles"], 'HighTimes').addArticles
	        else 
	        	ScraperError.email('HighTimes News', 'No Articles were returned').deliver	
	        end
	    rescue => ex
        	ScraperError.email('HighTimes News', ex.message).deliver
		end
           	
    end
end
