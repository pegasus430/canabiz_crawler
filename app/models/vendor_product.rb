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
            all.each do |vendor_product|
                values = vendor_product.attributes.values_at(*column_names)
                values += [vendor_product.vendor.name] if vendor_product.vendor
                values += [vendor_product.product.name] if vendor_product.product
                csv << values
            end
        end
    end
    
end