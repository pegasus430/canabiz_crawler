class PasswordReset < ApplicationMailer
	default_url_options[:host] = "localhost:3000"
	default from: "noreply@cannabiznetwork.com"
	
	def email(user)
		@user = user
		mail(to: @user.email, subject: 'Reset Password')
	end
end
