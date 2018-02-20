class VendorFinder
	
	attr_reader :params
	
	def initialize(params)
		@params = params
		@search_string = ''
	end
	
	
	def build
	    
        @vendors = Vendor.all
        @search_string = ''

        #only search either name or letter, not both
        if params[:name_search].present?
            @searched_name = params[:name_search]
            @vendors = @vendors.where("vendors.name LIKE ?", "%#{params[:name_search]}%")
            add_to_search(params[:name_search], ' and ')
        elsif params[:az_search].present?
            @az_letter = params[:az_search]
            @vendors = @vendors.where("vendors.name LIKE ?", "#{params[:az_search]}%")
            add_to_search(params[:az_search], ' and ')
        end
        
        #return values
        [@vendors, @search_string, @searched_name, @az_letter]

	end
	
	private
	
	def add_to_search(query, word)
		@search_string == '' ? @search_string += query : @search_string += (word + query)
	end
end