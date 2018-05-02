class OrdersController < ApplicationController

  include CurrentCart
  before_action :set_cart, only: [:new, :create]
  before_action :set_order, only: [:show, :edit, :destroy]
  
	def index
	  @orders = Order.all 
	end
	
	def new
		if @cart.product_items.empty?
			redirect_to root_path, notice: 'Your Cart is Empty'
			return
		end
		
		#i can make array of dispensaries here i think - 
		#or after order is saved i can do after_validation create DispensaryOrder records - 
		#but have to add the product items to it
		
		@dispensary = @cart.product_items[0].dispensary
		
		@order = Order.new
		@client_token = Braintree::ClientToken.generate
	end
	
	def create
		logger.info 'I AM IN HERE'
		@order = Order.new(order_params)
		@order.add_product_items_from_cart(@cart)
		if @order.save
			logger.info 'I AM IN HERE SAVED'
			logger.info @cart.total_price
			charge 
			if @result.success?
				Cart.destroy(session[:cart_id]) #no longer need cart with these products if order placed
				session[:cart_id] = nil
				#OrderNotifier.received(@order).deliver --> we should send email to us and dispensary email
				redirect_to root_path, notice: 'Thank You for Your Order!'
			else 
				flash[:error] = 'There was an error with payment'
				redirect_to root_path, alert: @result.message
				@order.destroy
			end
		else
			logger.info 'I AM IN HERE NOT SAVED'
		  render :new
		end
	end
	
	def show
	end
	
	def destroy
		@order.destroy
		redirect_to root_url, notice: 'Order deleted'
	end
	
	private
	
	def set_order
		@order = Order.find(params[:id])
	end
	
	def order_params
		params.require(:order).permit(:name, :email, :phone, :address, :city, :state, :country, :dispensary_source_id)
	end
	
	def charge
		#test braintree transaction
		@result = Braintree::Transaction.sale(
		  amount: @cart.total_price,
		  payment_method_nonce: params[:payment_method_nonce] )
	end
	
	after_validation :create_dispensary_source_orders
	def create_dispensary_source_orders
		
		dispensarySourceIds = Set.new
		self.product_items.each do |product_item|
			dispensarySourceIds.add(product_item.dispensary_source_id)
		end
		
		dispensary_source_orders = Array.new
		
		dispensarySourceIds.each do |setObject|
            dso = DispensarySourceOrder.create(:dispensary_source_id => setObject, :order_id => self.id)
            dispensary_source_orders.add(dso)
        end
		
		self.product_items.each do |product_item|
			
			dispensary_source_orders.each do |dso|
				if dso.dispensary_source_id == product_item.dispensary_source_id
					product_item.update_attribute :dispensary_source_order_id, dso.id
				end
			end
		end 
	end
  	
end