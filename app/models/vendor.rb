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
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            Vendor.create! row.to_hash
        end
    end    
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |vendor|
                values = vendor.attributes.values_at(*column_names)
                values += [vendor.image.to_s]
                values += [vendor.state.name] if vendor.state
                csv << values
            end
        end
    end
    
end