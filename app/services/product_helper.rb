class ProductHelper

	def initialize(product, state)
		@product = product
		@state = state
	end
	
	def findProductsPriceAndDistance()
		
		#hash returned
		@product_to_distance = Hash.new
		@product_to_closest_disp = Hash.new
		
		@products.each do |product|
			
			#distance
			if @ip_address != nil
				closest_distance = nil
				closest_dispensary = nil
				
				product.dispensary_sources.each do |dispSource|
					
					if closest_distance == nil || dispSource.distance_to(@ip_address) < closest_distance
						closest_distance = dispSource.distance_to(@ip_address).round(2)	
						closest_dispensary = dispSource.dispensary
					end
				end
				
				@product_to_distance.store(product, closest_distance)
				@product_to_closest_disp.store(product, closest_dispensary)
			end
		end
		
		#return
		[@product_to_distance, @product_to_closest_disp]
	end
	
	def buildProductDisplay()
		
        #get similar products
        if @product.is_dom.present?
            @similar_products = Product.featured.where.not(id: @product.id).
                        where(is_dom: @product.is_dom).order("Random()").limit(4)

        elsif @product.sub_category.present? 
            @similar_products = Product.featured.where.not(id: @product.id).
                        where(sub_category: @product.sub_category).
                        order("Random()").limit(4)
        
        elsif @product.category.present?
            @similar_products = @product.category.products.
                    featured.where.not(id: @product.id).order("Random()").limit(4)
        end
        
        
        
        #THIS IS WHERE I NEED THE WORK DONE: 
        
        # we take in a state and product 
        
        # 10 dispensaries sell the product - they have 30 dispensary sources between them - 
            # I would just want 10 dispensary sources (ideally source = 'Self' if not, last_menu_update desc)
        # the data model: dispensary (state_id) <-- dispensary source (state_id) 
        #                     <-- dispensary source product (product_id) <-- dsp_prices
        
        #first I want to see if there is a dispensary source where source name = 'Self' - if yes, take those dsps
        # if not, sort the rest by Last_Menu_Update (most recent)
        
        
        # disp_source_ids = DispensarySource.where(state_id: @state_id).pluck(:id)
        
        # dsps = DispensarySourceProduct.where(product_id: @product.id).where(dispensary_source_id: disp_source_ids)
        
        
        # dsps = @product.dispensary_sources.where(state_id: @state.id).dispensary_source_products.
        #             where(product_id: @product.id).includes(:dsp_prices, :dispensary_source)
        
        
        
        # dsps = @product.dispensary_source_products.
        # #             where(:dispensary_source => {state_id: @state.id}).
        #             includes(:dsp_prices)
                    
                    # s.where()
        
        @table_headers = Hash.new #for product table
        
        # puts 'dsp size::: '
        # puts dsps.count
        
        
        # dsps.each do |dsp|
            
        #     # get the th from dsp_prices
        #     dsp.dsp_prices.each do |dsp_price|
        #         if dsp_price.display_order.present?
        #             puts dsp_price.unit
        #             puts dsp_price.display_order
        #             @table_headers.store(dsp_price.display_order, dsp_price.unit)
        #         end     
        #     end
        # end
        
        
        
        
        
        #populate page maps - IF THEY HAVE A SELF ONE THEN AUTOMATICALLY USE THAT, IF NOT USE ANOTHER
        dispensary_sources = @product.dispensary_sources.where(state_id: @state.id).
                                includes(:dispensary, :state, :dispensary_source_products => :dsp_prices).
                                order('last_menu_update DESC').order("name ASC")
                                
        #need a map of dispensary to dispensary source product
        @dispensary_to_product = Hash.new
        header_options =  @product.dispensary_source_products.map{|dispensary_source| dispensary_source.dsp_prices.map(&:unit)}.flatten.uniq unless  @product.dispensary_source_products.blank?
        @table_header_options = DspPrice::DISPLAYS.sort_by {|key, value| value}.to_h.select{|k, v| k if header_options.include?(k)}.keys

        dispensary_sources.each do |dispSource|
            
            #get the th from dsp_prices
            dispSource.dispensary_source_products.each do |dsp|
                dsp.dsp_prices.each do |dsp_price|
                    if dsp_price.display_order != nil
                      @table_headers.store(dsp_price.display_order, dsp_price.unit)
                    end
                end
            end
            
            #dispensary products
            if !@dispensary_to_product.has_key?(dispSource)
                
                dsps = dispSource.dispensary_source_products.select { |dsp| dsp.product_id == @product.id}
                
                if dsps.size > 0
                    @dispensary_to_product.store(dispSource, dsps[0])
                end
            end
        end
        
        # {0 => 'Gram', 1 => 'Eighth', 2 => 'Ounce'}
        
        @table_headers = Hash[@table_headers.sort_by {|k,v| k.to_i }]
        
        #return
        [@similar_products, @dispensary_to_product, @table_headers, @table_header_options]
		
	end
	
end