module CurrentCart
	#we use this concern to manage current cart in the current session
	#using concerns we can use this private logic in our controllers
	
	private 
	
	def set_cart
		@cart = Cart.find(session[:cart_id]) #see if a cart currently exists for this session
		
		rescue ActiveRecord::RecordNotFound #cart not found
			@cart = Cart.create #create a new cart
			session[:cart_id] = @cart.id #set the session cart
	end
end