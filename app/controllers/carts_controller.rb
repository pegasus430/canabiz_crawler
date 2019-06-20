class CartsController < ApplicationController
	
	before_action :set_cart, only: [:show, :destroy]
	rescue_from ActiveRecord::RecordNotFound, with: :invalid_cart
	
	def new
		@cart = Cart.new
	end
	
	def show
	end
	
	def destroy
		# @cart.destroy if @cart.id == session[:cart_id]
		# redirect_to root_path, notice: 'Your Cart is Empty'
	end
	
	private 
	
	def set_cart 
		@cart = Cart.find(params[:id])
	end
	
	def cart_params
		params[:cart]
	end
	
	def invalid_cart
		# logger_error = 'You are trying to access an invalid cart'
		redirect_to root_path, notice: 'Invalid Cart'
	end
end