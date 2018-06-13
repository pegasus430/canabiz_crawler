class ProductFinder
	
	attr_reader :params
	
	def initialize(params)
		@params = params
		@search_string = ''
	end
	
	def build
                    
        add_state_to_string = false
		if params[:state_search].present?
            if @searched_state = State.find_by(name: params[:state_search])
                add_state_to_string = true

                @products = @searched_state.products.featured.
                left_join(:dispensary_source_products).group(:id).
                order('COUNT(dispensary_source_products.id) DESC').
	            includes(:category, :average_prices, :vendors, :dispensary_sources => :dispensary)
            end
        end
		
		if !add_state_to_string
    		@products = Product.featured.left_join(:dispensary_source_products).group(:id).
                order('COUNT(dispensary_source_products.id) DESC').
	            includes(:category, :average_prices, :vendors, :dispensary_sources => :dispensary)
	    end
            
        #only search either name or letter, not both
        if params[:name_search].present?
            @searched_name = params[:name_search]
            @products = @products.where("products.name LIKE ?", "%#{params[:name_search]}%")
            add_to_search(params[:name_search], ' and ')
        elsif params[:az_search].present?
            @az_letter = params[:az_search]
            if @az_letter == '#'
                @products = @products.
                where("products.name LIKE ? OR products.name LIKE ? OR products.name LIKE ? OR products.name LIKE ? OR products.name LIKE ? OR products.name LIKE ? OR products.name LIKE ? OR products.name LIKE ? OR products.name LIKE ? OR products.name LIKE ?",
                        "0%", "1%", "2%", "3%", "4%", "5%", "6%", "7%", "8%", "9%")
            else
                @products = @products.where("products.name LIKE ?", "#{params[:az_search]}%")
            end
            
            add_to_search(params[:az_search], ' and ')
        end

        if params[:category_search].present?
            if @searched_category = Category.find_by(name: params[:category_search])
                @products = @products.where(category_id: @searched_category.id) 
                add_to_search(params[:category_search], ' and ')
            #see if its a sub category
            elsif params[:category_search] == 'Hybrid-Sativa'
                @products = @products.where(is_dom: 'Sativa') 
                add_to_search(params[:category_search], ' and ')
            elsif params[:category_search] == 'Hybrid-Indica'
                @products = @products.where(is_dom: 'Indica') 
                add_to_search(params[:category_search], ' and ')
            elsif ['Indica', 'Sativa', 'Hybrid'].include? params[:category_search]
                @products = @products.where(sub_category: params[:category_search])
                add_to_search(params[:category_search], ' and ')
            end
        end
        
        if params[:location_search].present?
            @searched_location = params[:location_search]
            @products = @products.where('dispensary_sources.location like ?', "%#{params[:location_search]}%")
            add_to_search(params[:location_search], ' in ')
        end
        
        #add state value at the end
        if add_state_to_string
            add_to_search(params[:state_search], ' in ')
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