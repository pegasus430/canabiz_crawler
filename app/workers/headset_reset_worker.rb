class HeadsetWorker
    include Sidekiq::Worker
    
    def perform()
		logger.info "Headset Reset Worker is Running"

        resetCounters()
	end
	
	def resetCounters()
	    #scraper will run daily - like 1150pm - always reset the daily models, 
	    #if it's the beginning of the month, we reset the monthly
	    #if its the beginningg of week, we reset the weekly
	    
	    Boolean monthOrWeek = false
	    
	    if Date.today.sunday? 
	        monthOrWeek = true
            resetWeeklyCounters() 
	    end
	    
	    if !monthOrWeek
	        resetDailyCounters() 
	    end
	    
	end
	
	def resetWeeklyCounters()
		Product.where("headset_weekly_count > 0").or("headset_daily_count > 0")
			.or("headset_monthly_count > 0").each do |product|
			
			product.update_attribute :headset_monthly_count, 0
			product.update_attribute :headset_weekly_count, 0
			product.update_attribute :headset_daily_count, 0
		end
		
		ProductState.where("headset_weekly_count > 0").or("headset_daily_count > 0").each do |product_state|
			product_state.update_attribute :headset_weekly_count, 0
			product_state.update_attribute :headset_daily_count, 0
		end
	end

	def resetWeeklyCounters()
		Product.where("headset_weekly_count > 0").or("headset_daily_count > 0").each do |product|
			product.update_attribute :headset_weekly_count, 0
			product.update_attribute :headset_daily_count, 0
		end
		
		ProductState.where("headset_weekly_count > 0").or("headset_daily_count > 0").each do |product_state|
			product_state.update_attribute :headset_weekly_count, 0
			product_state.update_attribute :headset_daily_count, 0
		end
	end
	
	
	def resetDailyCounters()
		Product.where("headset_daily_count > 0").each do |product|
			product.update_attribute :headset_daily_count, 0
		end
		
		ProductState.where("headset_daily_count > 0").each do |product_state|
			product_state.update_attribute :headset_daily_count, 0
		end
	end
	
end