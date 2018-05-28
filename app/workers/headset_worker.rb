class HeadsetWorker
    include Sidekiq::Worker
    
    def perform()
		logger.info "Headset Worker is Running"
		state_string = 'washington colorado nevada'
        HeadsetScraperHelper.new(state_string).scrapeHeadset
	end
end