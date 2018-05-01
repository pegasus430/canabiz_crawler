class ProductItemsController < ApplicationController
	
	# https://www.benkirane.ch/ajax-bootstrap-modals-rails/
	
	include CurrentCart
	before_action :set_cart, only: [:create, :get_dsp_values]
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
		
		dispensary_source_products = DispensarySourceProduct.where(product_id: params[:product_id]).
										where(dispensary_source_id: params[:dispensary_source_id]).includes(:dsp_prices)
										
		if dispensary_source_products.size > 0
			@dsp_values = dispensary_source_products[0].dsp_prices
			@product_name = dispensary_source_products[0].product.name
			@product_id = params[:product_id]
			@dispensary_name = dispensary_source_products[0].dispensary_source.dispensary.name
			@dispensary_id = dispensary_source_products[0].dispensary_source.dispensary.id
			@dispensary_source_id = params[:dispensary_source_id]
		else 
			redirect_to root_path	
		end
		
		@product_item = ProductItem.new
		
		# params[@product_item][:cart_id] = @cart.id
		
		# @product_item.cart_id = @cart.id
		# @product_item.product_id = params[:product_id]
		# @product_item.dispensary_id = dispensary_source_products[0].dispensary_source.dispensary.id
		
		respond_to do |format|
			format.html
			format.js
		end
	end
	
	def create
		
		#we either get the shopping cart from the CurrentCart or create one if they dont have
		#i need to get the product, dispensary, and dspprice to create:
			# maybe the price will be popup when they click buy? and then i set param
			
			logger.info 'HERE ARE THE PARAMS'
		logger.info params
		
		@product_item = ProductItem.create(product_item_params) 
		#have to see if item is already in cart and if so add to it
		#that cart build method used to do this
		
		#@product_item = @cart.add_product(product.id, dispensary.id, dsp_price.id, 5)
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
		params.require(:product_item).permit(:product_id, :cart_id, :quantity, :dispensary_id, :dsp_price_id) 
	end
	
end