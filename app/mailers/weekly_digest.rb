class WeeklyDigest < ApplicationMailer
	default from: "noreply@cannabiznetwork.com"
	
	def email(user)
		@user = user
		mail(to: @user.email, subject: 'Cannabiz Network Weekly Roll Up')
	end
end
