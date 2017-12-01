class ProductFinder
	
	attr_reader :params
	
	def initialize(params)
		@params = params
		@search_string = ''
	end
	
	def build
		@products = Product.featured.includes(:category, :dispensary_sources, :vendors, :dispensary_source_products, :dispensary_sources => :dispensary)
            
        #only search either name or letter, not both
        if params[:name_search].present?
            @searched_name = params[:name_search]
            @products = @products.where("products.name LIKE ?", "%#{params[:name_search]}%")
            add_to_search(params[:name_search], ' and ')
        elsif params[:az_search].present?
            @az_letter = params[:az_search]
            @products = @products.where("products.name LIKE ?", "#{params[:az_search]}%")
            add_to_search(params[:az_search], ' and ')
        end

        if params[:category_search].present?
            if @searched_category = Category.find_by(name: params[:category_search])
                @products = @products.where(category_id: @searched_category.id) 
                add_to_search(params[:category_search], ' and ')
            end
        end
        
        if params[:location_search].present?
            @searched_location = params[:location_search]
            @products = @products.where('dispensary_sources.location like ?', "%#{params[:location_search]}%")
            add_to_search(params[:location_search], ' in ')
        end
       
        if params[:state_search].present?
            if @searched_state = State.find_by(name: params[:state_search])
                @products = @products.where(:dispensary_sources => {state_id: @searched_state.id})
               add_to_search(params[:state_search], ' in ')
            end
        end
        
        #return values
        [@products, @search_string, @searched_name, @az_letter, 
            @searched_category, @searched_location, @searched_state]
	end
	
	private
	
	def add_to_search(query, word)
		@search_string == '' ? @search_string += query : @search_string += (word + query)
	end
end