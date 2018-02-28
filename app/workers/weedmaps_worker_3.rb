class WeedMapsWorker3
	include Sidekiq::Worker

	def perform()
		require "json"
		logger.info "Weedmaps Job is running"
		WeedmapsScraperHelper.new(ENV['WEEDMAPS_STATE'], 'M-R').scrapeWeedmaps
	end
end