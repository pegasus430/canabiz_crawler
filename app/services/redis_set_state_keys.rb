class RedisSetStateKeys
	
	# have to set state news
	# have to set state dispensaries
	# have to set state vendors
	
	
	def initialize
	end
	
	def set_state_keys()
		State.each do |state|
			
			
			if state.product_state
				
				#set state vendors
				vendors = Vendor.where(state_id: state.id).order("RANDOM()")
				$redis.set("#{state.name.downcase}_vendors", Marshal.dump(vendors))
				
				#set state dispensaries
				dispensaries = Dispensary.where(state_id: @site_visitor_state.id).order("RANDOM()")
                $redis.set("#{@site_visitor_state.name.downcase}_dispensaries", Marshal.dump(dispensaries))
                
			end
		
		end
	end
end