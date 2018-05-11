class DispensarySource < ActiveRecord::Base
    
    #scope for admin panel
    scope :has_admin, -> { where.not(admin_user_id: nil) }
    
    #relationships
    belongs_to :source
    belongs_to :dispensary
    belongs_to :state
    belongs_to :admin_user
    
    has_many :dispensary_source_orders
    has_many :product_items
    
    has_many :dispensary_source_products, -> { order(:product_id => :asc) }
    has_many :products, through: :dispensary_source_products
    
    #validations
    validates :dispensary_id, presence: true
    validates :source_id, presence: true
    
    #geocode location
    geocoded_by :location
    after_validation :geocode
    
    #photo aws storage
    mount_uploader :image, PhotoUploader
    
    #delete relations on delete
    before_destroy :delete_relations
    def delete_relations
       self.dispensary_source_products.destroy_all
    end
    
    #set location from other fields
    def location
		"#{street}, #{city}, #{state.name}, #{zip_code}"
	end
    
end