class DispensaryOrder < ApplicationMailer
    default from: "noreply@cannabiznetwork.com"
	
	def email(dispensary_source, dispensary_source_order)
		@dispensary_source = dispensary_source
		@dispensary_source_order = dispensary_source_order

		mail(to: dispensary_source.admin_user.email, 
		    subject: "An Order has been placed to #{dispensary_source} on Cannabiz Network")
	end
end
