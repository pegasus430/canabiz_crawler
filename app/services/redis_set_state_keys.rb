class RedisSetStateKeys
	
	def initialize
	end
	
	def set_state_keys
	   State.each do |state|
	      
	      recents = state.articles.active_source.
                        includes(:source, :categories, :states).
                        order("created_at DESC")
	       
	   end
	end
end