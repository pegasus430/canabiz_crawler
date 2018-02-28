class DispWeedmaps < ActiveJob::Base
	include SuckerPunch::Job
	
	def perform(state_name, city_range)
		@state_name = state_name
		@city_range = city_range
		logger.info "Weedmaps Job is running"
		WeedmapsScraperHelper.new(@state_name, @city_range).scrapeWeedmaps 
	end
	
end #end of class