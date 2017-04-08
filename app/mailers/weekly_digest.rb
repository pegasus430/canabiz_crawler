class WeeklyDigest < ApplicationMailer
	default from: "noreply@cannabiznetwork.com"
	include TruncateHtmlHelper
	helper_method :truncate_html
	
	def email(user)
		@user = user
		#attachments.inline["cbz-logo-color.svg"] = File.read("#{Rails.root}/app/assets/images/header_footer/cbz-logo-color.svg")
		mail(to: @user.email, subject: 'Cannabiz Network Weekly Roll Up')
	end
end
