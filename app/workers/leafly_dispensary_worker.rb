class LeaflyDispensaryWorker
  include Sidekiq::Worker

	def perform()
		logger.info "Leafly Dispensary background job 1 is running"
		LeaflyScraperHelper.new(ENV['LEAFLY_STATE'], ENV['LEAFLY_CITY_RANGE']).scrapeLeafly
	end    
	
end #end of class