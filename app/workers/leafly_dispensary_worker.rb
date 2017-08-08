class LeaflyDispensaryWorker
  include Sidekiq::Worker

    def perform()
        logger.info "Leafly Dispensary background job is running"
        @start = DateTime.now
        scrapeLeafly()
    end    
    
    def scrapeLeafly()
        
        #store image
        #https://github.com/savon40/Cannabiz-SecondAttempt/commit/f7e51bb4f5153f073d4ffeb8d888e78a463e63e2
        
        require "json"
        require 'open-uri'
        
      #MAKE CALL AND CREATE JSON
      output = nil
      if ENV['LEAFLY_CITY_RANGE'] != nil && ENV['LEAFLY_CITY_RANGE'] != '' 
        output = IO.popen(["python", "#{Rails.root}/app/scrapers/leafly_disp_scraper.py", ENV['LEAFLY_STATE'], '--cityStarts='+ENV['LEAFLY_CITY_RANGE']])
      else
        output = IO.popen(["python", "#{Rails.root}/app/scrapers/leafly_disp_scraper.py", ENV['LEAFLY_STATE']]) #@state_abbr
      end
	    
	    contents = JSON.parse(output.read)
	    
	    logger.info 'size: '
	    #logger.info contents.size
	    #logger.info contents
	    
	    @end = DateTime.now
	    
	    ContactUs.email('Leafly Dispensary scraper complete for state: ' + ENV['LEAFLY_STATE'], 
	                      @start.strftime("%B %d, %Y | %I:%M %p"),
	                      @end.strftime("%B %d, %Y | %I:%M %p") + ', size:' + contents[ENV['LEAFLY_STATE']][0]).deliver
           	
    end    
	
end
