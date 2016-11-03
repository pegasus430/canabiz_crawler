class WeeklyDigest < ApplicationMailer
	default from: "steve@cannabiznetwork.com"
	
	def email(user)
		@user = user
		mail(to: @user.email, subject: 'Cannabiz Network Weekly Roll Up')
	end
end
