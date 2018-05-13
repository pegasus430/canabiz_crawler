class CustomerOrder < ApplicationMailer
    default from: "noreply@cannabiznetwork.com"
	
	def email(order)
		@order = order
		mail(to: order.email, subject: "Thank you for your order on Cannabiz Network")
	end
end
