class Product < ActiveRecord::Base
    
    #so I can just say Product.featured in query
    scope :featured, -> { where(featured_product: true).where.not(image: nil) }
    
    #lookups
    belongs_to :category
    belongs_to :state
    
    has_many :vendor_products, -> { order(:units_sold => :desc) }
    has_many :vendors, through: :vendor_products
    
    #average prices has lookup to product
    has_many :average_prices, -> { order(:display_order => :asc) }
    
    #many-to-many with
    has_many :dispensary_source_products
    has_many :dispensary_sources, through: :dispensary_source_products
    
    #friendly url
    extend FriendlyId
    friendly_id :name, use: :slugged
    
    #photo aws storage
    mount_uploader :image, PhotoUploader
    
    #validations
    validates :name, presence: true
    validates_uniqueness_of :name, :scope => :category_id #no duplicate products per category
    
    #import CSV file
    def self.import_via_csv(products)
        CSV.parse(products, :headers => true).each do |row|
            
            #change to update record if id matches
            product_hash = row.to_hash
            product = self.where(id: product_hash["id"])
            
            if product.present? 
                product.first.update_attributes(product_hash)
            else
                Product.create! product_hash
            end
        end
    end    
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |product|
                values = product.attributes.values_at(*column_names)
                values += [product.image.to_s]
                values += [product.category.name] if product.category
                csv << values
            end
        end
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