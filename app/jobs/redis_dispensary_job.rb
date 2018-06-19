class RedisDispensaryJob < ActiveJob::Base
    include SuckerPunch::Job
    
    def perform()
        puts 'Redis Vendor Job is Running'
        RedisSetDispensaryKeys.new().set_dispensary_keys()    
    end
end