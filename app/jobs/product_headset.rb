class ProductHeadset < ActiveJob::Base
    include SuckerPunch::Job
 
    def perform()
        logger.info "Headset background job is running"
        scrapeHeadset()
    end    
    
    def scrapeHeadset()
        
        require "json"
        require 'open-uri'
        
        begin
	        output = IO.popen(["python", "#{Rails.root}/app/scrapers/headset_disp_scraper.py", "washington"])
	        contents = JSON.parse(output.read)
	        
	        #call method
			logger.info "here are the results: " 
			logger.info contents
		rescue => ex
			logger.info "THERE WAS A HEADSET ERROR: "
			logger.info ex.message
		end
    end    
end