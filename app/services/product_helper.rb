class ProductHelper

	def initialize(product, state, average_price)
		@product = product
		@state = state
		@average_price = average_price
	end
	
	def buildSimilarProducts()
	    #similar products - include is_dom and sub_category as well
        if @product.category.present?

            @similar_products = @product.category.products.featured.where.not(id: @product.id)
            
            if @product.is_dom.present?
            
                @similar_products = @similar_products.where(is_dom: @product.is_dom.strip).order("Random()").limit(4)
                similar_products_count = @similar_products.count
                if similar_products_count < 4
                    sub_category_products =  @similar_products.where(sub_category: @product.sub_category.strip).order("Random()").limit(4 - similar_products_count)
                    sub_category_products.each do |sub_cat_prod|
                       @similar_products << sub_cat_prod
                    end
                end
                
            elsif @product.sub_category.present?
                @similar_products = @similar_products.where(sub_category: @product.sub_category.strip).order("Random()").limit(4)
                similar_products_count = @similar_products.count
                if similar_products_count < 4
                    category_products =  @product.category.products.featured.where.not(id: @product.id).order("Random()").limit(4 - similar_products_count)
                    category_products.each do |cat_prod|
                       @similar_products << cat_prod
                    end
                end
            else
                @similar_products = @similar_products.order("Random()").limit(4)    
            end
            
        else
            @similar_products = Product.featured.order("Random()").limit(4)  
        end
        
        #return
        [@similar_products]
        
	end
	
	def buildProductDisplay()
	    
	    
	    #populate page maps - IF THEY HAVE A SELF ONE THEN AUTOMATICALLY USE THAT, IF NOT USE ANOTHER
        # dispensary_sources = @product.dispensary_sources.where(state_id: @state.id).
        #                         includes(:dispensary, :state, :dispensary_source_products => :dsp_prices).
        #                         order('last_menu_update DESC').order("name ASC")
                                
	    #gotta put average price in here as well
	    
	    if @average_price.present?
	        
	        @dispensary_source_products = @product.dispensary_source_products.includes(:product, :dispensary_source, :dsp_prices).
                where("dispensary_sources.state_id =?", @state.id).
                where('dsp_prices.unit like ?', @average_price.average_price_unit).
                where('dsp_prices.price <= ?', @average_price.average_price).
                order('dispensary_sources.last_menu_update DESC').order("dispensary_sources.name ASC").
                references(:dispensary_sources, :dsp_prices)
	        
	    else 
	        @dispensary_source_products = @product.dispensary_source_products.includes(:product, :dispensary_source, :dsp_prices).
                where("dispensary_sources.state_id =?", @state.id).
                order('dispensary_sources.last_menu_update DESC').order("dispensary_sources.name ASC").
                references(:dispensary_sources)   
	    end
        
        @header_options =  @dispensary_source_products.map{|dispensary_source_product| dispensary_source_product.dsp_prices.map(&:unit)}.flatten.uniq  unless  @dispensary_source_products.blank?

        if @header_options != nil
            @table_header_options = DspPrice::DISPLAYS.sort_by {|key, value| value}.to_h.select{|k, v| k if @header_options.include?(k)}.keys
        else 
            @table_header_options = nil
        end
        
        @dispensary_to_product = Hash.new
        @dispensary_source_products.each do |dsp|
            
            if !@dispensary_to_product.has_key?(dsp.dispensary_source)
                @dispensary_to_product.store(dsp.dispensary_source, dsp)
            end
                
        end
        
        
        # dispensary_sources.each do |dispSource|
            
        #     #dispensary products
        #     if !@dispensary_to_product.has_key?(dispSource)
                
        #         dsps = dispSource.dispensary_source_products.select { |dsp| dsp.product_id == @product.id}
                
        #         if dsps.size > 0
        #             @dispensary_to_product.store(dispSource, dsps[0])
        #         end
        #     end
        # end
        
        #return
        [@dispensary_to_product, @table_header_options]
	end
end