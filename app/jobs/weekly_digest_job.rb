class WeeklyDigestJob < ActiveJob::Base
  include SuckerPunch::Job

    def perform()
        logger.info "Weekly Digest is being Sent"
        sendDigest()
    end 
    
    def sendDigest()
      DigestEmail.where(active: true).each do |user|
      	WeeklyDigest.email(user).deliver	
      end
    end
end
