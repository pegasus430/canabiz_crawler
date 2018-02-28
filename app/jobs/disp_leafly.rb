class DispLeafly < ActiveJob::Base
    include SuckerPunch::Job

	def perform(state_abbreviation, city_range)
		logger.info "Leafly Dispensary background job is running"
		@state_abbreviation = state_abbreviation
		@city_range = city_range
		LeaflyScraperHelper.new(@state_abbreviation, @city_range).scrapeLeafly
	end
	
end #end of class
