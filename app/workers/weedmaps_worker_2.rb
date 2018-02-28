class WeedMapsWorker2
	include Sidekiq::Worker

	def perform()
		require "json"
		logger.info "Weedmaps Job is running"
		WeedmapsScraperHelper.new(ENV['WEEDMAPS_STATE'], 'G-L').scrapeWeedmaps
	end
end