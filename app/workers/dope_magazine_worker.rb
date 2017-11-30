class DopeMagazineWorker
  include Sidekiq::Worker

    def perform()
    	
    	logger.info "Dope Magazine background job is running"
        scrapeDopeMagazine()	
    end
    
    def scrapeDopeMagazine()
        
        require "json"
        require 'open-uri'
        
        begin
	        output = IO.popen(["python", "#{Rails.root}/app/scrapers/newsparser_dopemagazine.py"]) #cmd,
	        contents = JSON.parse(output.read)
	        
			#call method
	        if contents["articles"].present?
	        	NewsScraperHelper.new(contents["articles"], 'Dope Magazine').addArticles
	        else 
	        	ScraperError.email('Dope Magazine News', 'No Articles were returned').deliver_now	
	        end
	    rescue => ex
        	ScraperError.email('Dope Magazine News', ex.message).deliver_now
		end
    end
end
