class ScraperError < ApplicationMailer
	default from: "noreply@cannabiznetwork.com"
	
	def email(scraper, error_message)
		@scraper = scraper
		@error_message = error_message
		emails = ['steve@cannabiznetwork.com', 'michael@cannabiznetwork.com']
		mail(to: emails, subject: 'There was an Error with one of the Scrapers')
	end
end
