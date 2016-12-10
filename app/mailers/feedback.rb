class Feedback < ApplicationMailer
	default from: "noreply@cannabiznetwork.com"
	
	def email(firstTime, primaryReason, findEverything, reasonDidntFind, easyInformation, likelihood, suggestion)
		@firstTime = firstTime
		@primaryReason = primaryReason
		@findEverything = findEverything
		@reasonDidntFind = reasonDidntFind
		@easyInformation = easyInformation
		@likelihood = likelihood
		@suggestion = suggestion
		mail(to: 'steve@cannabiznetwork.com', subject: 'New Feedback Submission')
	end
end
