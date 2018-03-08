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
    
    #geocode location
    geocoded_by :address
    after_validation :geocode
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            
            vendor_hash = row.to_hash
            vendor = self.where(id: vendor_hash["id"])
            
            if vendor.present?
                vendor.first.update_attributes(vendor_hash)
            else
                Vendor.create! vendor_hash
            end
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
    
    #delete relations
    before_destroy :delete_relations
    def delete_relations
       self.vendor_products.destroy_all
    end
    
end