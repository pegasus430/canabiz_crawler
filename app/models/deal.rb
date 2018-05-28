class Deal < ActiveRecord::Base
    
    #relations
    belongs_to :dispensary
    belongs_to :state #i stil have to create the field on deal
    
    #photo aws storage
    mount_uploader :image, PhotoUploader
    
end