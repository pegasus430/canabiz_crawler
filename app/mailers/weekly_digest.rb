class WeeklyDigest < ApplicationMailer
	default from: "noreply@cannabiznetwork.com"
	include TruncateHtmlHelper
	helper_method :truncate_html
	
	def email(user)
		@user = user
		mail(to: @user.email, subject: 'Cannabiz Network Weekly Roll Up')
	end
end
