class ProductHeadset < ActiveJob::Base
    include SuckerPunch::Job
 
	def perform(state_string)
        HeadsetScraperHelper.new(state_string).scrapeHeadset 
    end    

end