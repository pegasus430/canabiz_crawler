class WeeklyDigestJob < ActiveJob::Base
    include SuckerPunch::Job

    def perform()
        logger.info "Weekly Digest is being Sent"
        sendDigest()
    end 
    
    def sendDigest()
        
        
        #ONLY SENDING TO ME AND PASS RIGHT NOW
        DigestEmail.where(active: true).each do |user|
            
            if user.email == 'savon40@gmail.com' || user.email == 'michael@cannabiznetwork.com'
                WeeklyDigest.email(user).deliver	
            end
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
