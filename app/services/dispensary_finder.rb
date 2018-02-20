class DispensaryFinder
	
	attr_reader :params
	
	def initialize(params)
		@params = params
		@search_string = ''
	end
	
	
	def build
	    
        @dispensaries = Dispensary.all.order("name ASC")
        @search_string = ''
        
        if params[:name_search].present?
            name = "%#{params[:name_search]}%"
            @dispensaries = @dispensaries.where("name LIKE ?", name)
            @search_string += params[:name_search]
        end
        
        #only search either name or letter, not both
        if params[:name_search].present?
            @searched_name = params[:name_search]
            @dispensaries = @dispensaries.where("dispensaries.name LIKE ?", "%#{params[:name_search]}%")
            add_to_search(params[:name_search], ' and ')
        elsif params[:az_search].present?
            @az_letter = params[:az_search]
            if @az_letter == '#'
                @dispensaries = @dispensaries.
                where("dispensaries.name LIKE ? OR dispensaries.name LIKE ? OR dispensaries.name LIKE ? OR dispensaries.name LIKE ? OR dispensaries.name LIKE ? OR dispensaries.name LIKE ? OR dispensaries.name LIKE ? OR dispensaries.name LIKE ? OR dispensaries.name LIKE ? OR dispensaries.name LIKE ?",
                        "0%", "1%", "2%", "3%", "4%", "5%", "6%", "7%", "8%", "9%")
            else
                @dispensaries = @dispensaries.where("dispensaries.name LIKE ?", "#{params[:az_search]}%")
            end
            add_to_search(params[:az_search], ' and ')
        end
        
        if params[:location_search].present?
            @searched_location = params[:location_search]
            @dispensaries = @dispensaries.where("dispensaries.location LIKE ?", "%#{params[:location_search]}%")
            add_to_search(params[:location_search], ' in ')
        end
       
        if params[:state_search].present?
            if @searched_state = State.find_by(name: params[:state_search])
                @dispensaries = @dispensaries.where(state_id: @searched_state.id)
                add_to_search(params[:state_search], ' in ')
            end
        end
        
        #return values
        [@dispensaries, @search_string, @searched_name, @az_letter, 
            @searched_location, @searched_state]

	end
	
	private
	
	def add_to_search(query, word)
		@search_string == '' ? @search_string += query : @search_string += (word + query)
	end
end