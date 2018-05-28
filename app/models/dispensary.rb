class Dispensary < ActiveRecord::Base

    #scope for admin panel
    scope :has_admin, -> { where.not(admin_user_id: nil) }
    
    #validations
    belongs_to :state
    validates :name, presence: true, length: {minimum: 1, maximum: 300}
    
    #relationships
    has_many :dispensary_sources
    has_many :sources, through: :dispensary_sources
    has_many :deals
    
    #geocode location
    geocoded_by :location
    after_validation :geocode
    
    #friendly url
    extend FriendlyId
    friendly_id :name, use: :slugged
    
    #photo aws storage
    mount_uploader :image, PhotoUploader
    
    #delete relations
    before_destroy :delete_relations
    def delete_relations
        self.deals.destroy_all
        self.dispensary_sources.destroy_all
    end
    
end #end dispensary class