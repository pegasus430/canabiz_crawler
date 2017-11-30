class NewsLeafly < ActiveJob::Base
    include SuckerPunch::Job
 
    def perform()
        logger.info "Leafly background job is running"
        scrapeLeafly()
    end    
    
    def scrapeLeafly()
 
        require "json"
        require 'open-uri'
        
        begin
	        output = IO.popen(["python", "#{Rails.root}/app/scrapers/newsparser_leafly.py"]) #cmd,
	        contents = JSON.parse(output.read)
	        
	        #call method:
	        if contents["articles"].present?
	        	NewsScraperHelper.new(contents["articles"], 'Leafly').addArticles
	        else 
	        	ScraperError.email('Leafly News', 'No Articles were returned').deliver_now	
	        end	
	    rescue => ex
        	ScraperError.email('Leafly News', ex.message).deliver_now
		end
    end    
end