class Product < ActiveRecord::Base
    
    #scope
    scope :featured, -> { where(featured_product: true).where.not(image: nil) }
    
    #relationships
    belongs_to :category
    
    has_many :product_states
    has_many :states, through: :product_states
    
    has_many :vendor_products, -> { order(:units_sold => :desc) }
    has_many :vendors, through: :vendor_products
    
    has_many :average_prices, -> { order(:display_order => :asc) }
    
    has_many :dispensary_source_products
    has_many :dispensary_sources, through: :dispensary_source_products
    
    has_many :product_items
    
    #validations
    validates :name, presence: true
    validates_uniqueness_of :name, :scope => :category_id #no duplicate products per category
    
    #friendly url
    extend FriendlyId
    friendly_id :name, use: :slugged
    
    #photo aws storage
    mount_uploader :image, PhotoUploader
    
    #increment the counters for headset whenever an existing product appears
    def increment_counters
       self.headset_alltime_count += 1 
       self.headset_monthly_count += 1
       self.headset_weekly_count += 1
       self.headset_daily_count += 1
       self.save
    end
    
    #delete relations
    before_destroy :delete_relations
    def delete_relations
       self.dispensary_source_products.destroy_all
       self.average_prices.destroy_all
    end
    
    #----------ECOMMERCE STUFF-----------
    before_destroy :ensure_not_product_item
	has_many :product_items
	
	#method to prevent destroy product if it is in a cart
	def ensure_not_product_item
		if product_items.empty?
			return true
		else
			errors.add(:base, 'This item is in a shopping cart')
			return false
		end
	end
    
end