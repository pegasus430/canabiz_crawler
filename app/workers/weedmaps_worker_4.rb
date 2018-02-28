class WeedMapsWorker4
	include Sidekiq::Worker

	def perform()
		require "json"
		@city_range = 'S-Z'
		@state_name = ENV['WEEDMAPS_STATE']
		logger.info "Weedmaps Job is running"
		WeedmapsScraperHelper.new(ENV['WEEDMAPS_STATE'], 'S-Z').scrapeWeedmaps
	end
end