class PasswordReset < ApplicationMailer
	default_url_options[:host] = "https://cannabiz-news.herokuapp.com"
	default from: "noreply@cannabiznetwork.com"
	
	def email(user)
		@user = user
		mail(to: @user.email, subject: 'Reset Password')
	end
end
