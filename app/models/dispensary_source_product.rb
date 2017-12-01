class DispensarySourceProduct < ActiveRecord::Base
    belongs_to :product
    belongs_to :dispensary_source
    
    validates :dispensary_source_id, presence: true
    
    validates_uniqueness_of :product_id, :scope => :dispensary_source_id #no duplicate products per dispensary
    
    #photo aws storage
    mount_uploader :image, PhotoUploader
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            DispensarySourceProduct.create! row.to_hash
        end
    end
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |dispensarySourceProduct|
                csv << dispensarySourceProduct.attributes.values_at(*column_names)
            end
        end
    end    
end