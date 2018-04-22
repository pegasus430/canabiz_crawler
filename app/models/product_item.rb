class ProductItem < ActiveRecord::Base
  
  #it is connected to a product because user is buying a product
  #it is connected to a dispensary because user is buying a product from a dispensary
  #it is connected to dsp_price because user is buying at a certain price/unit that dispensary sells at
  #user stores in cart
  
  belongs_to :product
  belongs_to :dispensary
  belongs_to :dsp_price
  belongs_to :cart
end
