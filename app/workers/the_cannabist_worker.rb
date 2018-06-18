class TheCannabistWorker
    include Sidekiq::Worker

    def perform()
        logger.info "The Cannabist background job is running"
        scrapeCannabist()
    end    
    
    def scrapeCannabist()
        
        require "json"
        require 'open-uri'
        
        begin
	        output = IO.popen(["python", "#{Rails.root}/app/scrapers/newsparser_thecannabist.py"]) #cmd,
	        contents = JSON.parse(output.read)
	        
	        #call method
			if contents["articles"].present?
				NewsScraperHelper.new(contents["articles"], 'The Cannabist').addArticles
			else 
	        	ScraperError.email('TheCannabist News', 'No Articles were returned').deliver	
	        end  	
		rescue => ex
        	ScraperError.email('TheCannabist News', ex.message).deliver_now
		end
    end    
end
