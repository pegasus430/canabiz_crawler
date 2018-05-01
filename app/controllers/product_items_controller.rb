class ProductItemsController < ApplicationController
	
	# https://www.benkirane.ch/ajax-bootstrap-modals-rails/
	
	include CurrentCart
	before_action :set_cart, only: [:create]
	before_action :set_product_item, only: [:show, :destroy]
	skip_before_action :verify_authenticity_token #for ajax
	
	def new
		@product_item = ProductItem.new
		logger.info 'HERE ARE THE PARAMS'
		logger.info params
		# logger.info 'product id: ' + params[:product_id]
		# logger.info 'dispensary id: ' + params[:dispensary_id]
	end
	
	def get_dsp_values
	
		logger.info 'HERE ARE THE PARAMS: '
		logger.info params
		@controller_variable = 'hello steve!!!'
		
		params[:product_id]
		params[:dispensary_source_id]
		
		@dispensary_source_products = DispensarySourceProduct.where(product_id: params[:product_id]).
										where(dispensary_source_id: params[:dispensary_source_id]).includes(:dsp_prices)
		
		respond_to do |format|
			format.html
			format.js
		end
	end
	
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
		
		
		@product_item = @cart.add_product(product.id, dispensary.id, dsp_price.id, 5)
		if @product_item.save
		  redirect_to root_path, notice: 'Product added to Cart'
		else
		  redirect_to root_path, notice: 'Could Not Add Item To Cart'
		end
	end
	
	def add_to_cart
	end
	
	# def get_dsp_values
	# 	logger.info 'here is the id: ' + params[:disp_source_id]
	# 	logger.info 'here is the product id: ' + params[:productId]
		
	# 	dispensary_source_products = DispensarySourceProduct.where(dispensary_source_id: params[:disp_source_id])
	# 									.where(product_id: params[:productId]).includes(:dsp_prices)
										
	# 	if dispensary_source_products.size > 0 
	# 		@dsp_prices = dispensary_source_products[0].dsp_prices
	# 	else
	# 		redirect_to root_path	
	# 	end
		
	# 	#@dsp_prices_for_cart = DSPPrice.where()
		
	# 	# if @dispensary_to_product.has_key?(params[:dispensary_key_id])
			
	# 	# end
	# end
	
	private
	
	def set_product_item
		@product_item = ProductItem.find(params[:id])
	end
	
	def product_item_params
		params.require(:product_item).permit(:product_id) 
	end
	
end