class UnitMissing < ApplicationMailer
    default from: "noreply@cannabiznetwork.com"
	
	def email(source_name, unit, price)
		@unit = unit
		@source_name = source_name
		@price = price
		emails = ['steve@cannabiznetwork.com']
		mail(to: emails, subject: 'A Unit needs to be added')
	end
end