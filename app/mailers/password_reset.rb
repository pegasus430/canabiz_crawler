class PasswordReset < ApplicationMailer
	default from: "noreply@cannabiznetwork.com"
	
	def email(user)
		@user = user
		mail(to: @user.email, subject: 'Reset Password')
	end
end
