class RedisSetStateKeys
	
	# have to set state news
	# have to set state dispensaries
	# have to set state vendors
	
	
	def initialize
	end
	
	def set_state_keys()
		State.each do |state|
			
			#set state vendors
			if state.product_state
				vendors = Vendor.where(state_id: state.id).order("RANDOM()")
				$redis.set("#{state.name.downcase}_vendors", Marshal.dump(vendors))
			end
		
		end
	end
end