class ContactUs < ApplicationMailer
	default from: "noreply@cannabiznetwork.com"
	
	def email(name, email, message)
		@name = name
		@email = email
		@message = message
		mail(to: 'steve@cannabiznetwork.com', subject: 'New Submission on Contact Form')
	end
end
