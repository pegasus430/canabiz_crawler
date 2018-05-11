class Vendor < ActiveRecord::Base
    
    #relationships
    has_many :vendor_products
    has_many :products, through: :vendor_products
    belongs_to :state
    
    #friendly url
    extend FriendlyId
    friendly_id :name, use: :slugged
    
    #photo aws storage
    mount_uploader :image, PhotoUploader
    
    #geocode location
    geocoded_by :address
    after_validation :geocode
    
    #delete relations
    before_destroy :delete_relations
    def delete_relations
       self.vendor_products.destroy_all
    end
    
end