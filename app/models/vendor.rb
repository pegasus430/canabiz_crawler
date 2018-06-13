class Vendor < ActiveRecord::Base
    
    #relationships
    has_many :vendor_products
    has_many :products, through: :vendor_products
    
    has_many :vendor_states
    has_many :states, through: :vendor_states
    
    #validations
    validates :name, presence: true
    validates_uniqueness_of :name
    
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
       self.vendor_states.destroy_all
    end
    
    #set redis key after save
    after_save :set_redis_key
    def set_redis_key
        if self.slug.present?
            $redis.set("vendor_#{self.slug}", Marshal.dump(self))   
        end
    end
    
end