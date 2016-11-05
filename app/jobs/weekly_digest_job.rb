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
      
        clearDigestArticles()
    end
    
    def clearDigestArticles()
        Article.where(include_in_digest: true).each do |article|
            article.include_in_digest = false
            article.save
        end
    end
end
