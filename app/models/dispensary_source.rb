class DispensarySource < ActiveRecord::Base
    #relations
    belongs_to :source
    belongs_to :dispensary
    belongs_to :state
    belongs_to :admin_user
    
    has_many :dispensary_source_orders
    has_many :product_items
    
    #many to many with products
    has_many :dispensary_source_products, -> { order(:product_id => :asc) }
    has_many :products, through: :dispensary_source_products
    
    #scope for admin panel
    scope :has_admin, -> { where.not(admin_user_id: nil) }
    scope :self, -> { where("source.name = 'Self'") }
    
    validates :dispensary_id, presence: true
    
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
    
    #delete relations
    before_destroy :delete_relations
    def delete_relations
       self.dispensary_source_products.destroy_all
    end
    
    #set location if needed
    #before_save :set_location
    # def set_location
    #     if self.state.present?
    #         self.location = self.street + ', ' + self.city + ', ' + 
				# 			self.state.name + ' ' + self.zip_code
    #     else
    #         self.location = self.street + ', ' + self.city + ' ' + self.zip_code
    #     end
    # end
    
end