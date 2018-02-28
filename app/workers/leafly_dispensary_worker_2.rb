class LeaflyDispensaryWorker2
  include Sidekiq::Worker

	def perform()
		logger.info "Leafly Dispensary background job 2 is running"
		LeaflyScraperHelper.new(ENV['LEAFLY_STATE'], 'G-L').scrapeLeafly
	end    
	
end #end of class