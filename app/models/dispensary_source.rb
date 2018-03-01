class DispensarySource < ActiveRecord::Base
    belongs_to :source
    belongs_to :dispensary
    belongs_to :state
    
    #many to many with products
    has_many :dispensary_source_products, -> { order(:product_id => :asc) }
    has_many :products, through: :dispensary_source_products
    
    validates :dispensary_id, presence: true
    
    #validates_uniqueness_of :product_id, :scope => :dispensary_id #no duplicate products per dispensary
    
    #geocode location
    geocoded_by :location
    after_validation :geocode
    
    #photo aws storage
    mount_uploader :image, PhotoUploader
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            DispensarySource.create! row.to_hash
        end
    end
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |dispensarySource|
                csv << dispensarySource.attributes.values_at(*column_names)
            end
        end
    end    
end