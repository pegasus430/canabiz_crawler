class Feedback < ApplicationMailer
	default from: "noreply@cannabiznetwork.com"
	
	def email(firstTime, primaryReason, findEverything, reasonDidntFind, easyInformation, likelihood)
		@firstTime = firstTime
		@primaryReason = primaryReason
		@findEverything = findEverything
		@reasonDidntFind = reasonDidntFind
		@easyInformation = easyInformation
		@likelihood = likelihood
		mail(to: 'steve@cannabiznetwork.com', subject: 'New Feedback Submission')
	end
end
