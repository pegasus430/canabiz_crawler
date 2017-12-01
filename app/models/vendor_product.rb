class VendorProduct < ActiveRecord::Base
    
    belongs_to :vendor
    belongs_to :product
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            VendorProduct.create! row.to_hash
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