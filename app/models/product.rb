class Product < ActiveRecord::Base
    
    #so I can just say Product.featured in query
    scope :featured, -> { where(featured_product: true).where.not(image: nil) }
    
    #lookups
    belongs_to :category
    
    has_many :vendor_products, -> { order(:units_sold => :desc) }
    has_many :vendors, through: :vendor_products
    
    #average prices has lookup to product
    has_many :average_prices, -> { order(:display_order => :asc) }
    
    #many-to-many with
    has_many :dispensary_source_products
    has_many :dispensary_sources, through: :dispensary_source_products
    
    #delete related DispensarySourceProducts
    before_destroy :delete_dispensary_source_products
    
    #friendly url
    extend FriendlyId
    friendly_id :name, use: :slugged
    
    #photo aws storage
    mount_uploader :image, PhotoUploader
    
    #validations
    validates :name, presence: true
    validates_uniqueness_of :name, :scope => :category_id #no duplicate products per category
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true, skip_blanks: true) do |row|
            Product.create! row.to_hash
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
    
    def delete_dispensary_source_products
       self.dispensary_source_products.destroy_all 
    end
    
end