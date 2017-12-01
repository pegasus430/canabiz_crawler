class Vendor < ActiveRecord::Base
    
    has_many :vendor_products
    has_many :products, through: :vendor_products
    
    #friendly url
    extend FriendlyId
    friendly_id :name, use: :slugged
    
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
                csv << vendor.attributes.values_at(*column_names)
            end
        end
    end
    
end