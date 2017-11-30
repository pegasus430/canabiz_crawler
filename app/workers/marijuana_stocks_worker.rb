class MarijuanaStocksWorker
  include Sidekiq::Worker

  def perform()
        logger.info "Marijuana Stocks background job is running"
        scrapeMarijuanaStocks()
    end    
    
    def scrapeMarijuanaStocks()
        
        require "json"
        require 'open-uri'
        
        begin
	        output = IO.popen(["python", "#{Rails.root}/app/scrapers/newsparser_marijuanastocksnews.py"]) #cmd,
	        contents = JSON.parse(output.read)
	        
	        #call method
	        if contents["articles"].present?
	        	NewsScraperHelper.new(contents["articles"], 'Marijuana Stocks').addArticles
	        else 
	        	ScraperError.email('MarijuanaStocks News', 'No Articles were returned').deliver_now	
	        end
	    rescue => ex
        	ScraperError.email('MarijuanaStocks News', ex.message).deliver_now
		end
    end
end
