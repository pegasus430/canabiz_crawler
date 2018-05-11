class ProductItem < ActiveRecord::Base
  
    #it is connected to a product because user is buying a product
    #it is connected to a dispensary_source because user is buying a product from a dispensary (source related to admin)
    #it is connected to dsp_price because user is buying at a certain price/unit that dispensary sells at
    #user stores in cart
    
    belongs_to :product
    belongs_to :dispensary_source
    belongs_to :dsp_price
    belongs_to :cart
    belongs_to :order
    belongs_to :dispensary_source_order
    
    def total_price
        dsp_price.price * quantity
    end
end
