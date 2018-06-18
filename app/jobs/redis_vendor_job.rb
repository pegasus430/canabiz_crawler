class RedisVendorJob < ActiveJob::Base
    include SuckerPunch::Job
    
    def perform()
        puts 'Redis Vendor Job is Running'
        RedisSetVendorKeys.new().set_vendor_keys()    
    end
end