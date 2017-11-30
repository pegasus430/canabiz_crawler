class MjBizDailyWorker
    include Sidekiq::Worker

    def perform()
        logger.info "MjBizDaily background job is running"
        
        scrapeMJBizDaily()
    end
    
    def scrapeMJBizDaily()
        
        require "json"
        require 'open-uri'
        
        begin
			output = IO.popen(["python", "#{Rails.root}/app/scrapers/newsparser_mjbizdaily.py"]) #cmd,
			contents = JSON.parse(output.read)
			
			#call method
			if contents["articles"].present?
				NewsScraperHelper.new(contents["articles"], 'MJ Biz Daily').addArticles
			else 
	        	ScraperError.email('MjBizDaily News', 'No Articles were returned').deliver_now	
	        end
	    rescue => ex
    		ScraperError.email('MjBizDaily News', ex.message).deliver_now
		end
    end 
end
