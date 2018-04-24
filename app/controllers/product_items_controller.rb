class ProductItemsController < ApplicationController
	
	include CurrentCart
	before_action :set_cart, only: [:create]
	before_action :set_product_item, only: [:show, :destroy]
	
	def create
		
		#we either get the shopping cart from the CurrentCart or create one if they dont have
		#i need to get the product, dispensary, and dspprice to create:
			# maybe the price will be popup when they click buy? and then i set param
		
		logger.info 'product id: ' + params[:product_id]
		product = Product.find(params[:product_id])
		logger.info 'HERE IS THE PRODUCT' 
		logger.info product.name
		
		logger.info 'dispensary id: ' + params[:dispensary_id]
		dispensary = Dispensary.find(params[:dispensary_id])
		logger.info 'HERE IS THE DISPENSARY' 
		logger.info dispensary.name
		
		logger.info 'dsp_price id: ' + params[:dsp_price_id]
		dsp_price = DspPrice.find(params[:dsp_price_id])
		logger.info 'HERE IS THE dsp_price' 
		logger.info dsp_price.price
		
		
		@product_item = @cart.add_product(product.id, dispensary.id, dsp_price.id)
		if @product_item.save
		  redirect_to root_path, notice: 'Product added to Cart'
		else
		  redirect_to root_path, notice: 'Could Not Add Item To Cart'
		end
	end
	
	private
	
	def set_product_item
		@product_item = ProductItem.find(params[:id])
	end
	
	def product_item_params
		params.require(:product_item).permit(:product_id) 
	end
	
end