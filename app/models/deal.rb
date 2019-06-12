class Deal < ActiveRecord::Base

    belongs_to :dispensary
    belongs_to :state
    
    mount_uploader :image, PhotoUploader
end