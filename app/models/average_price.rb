class AveragePrice < ActiveRecord::Base
    
    #lookups
    belongs_to :product
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            AveragePrice.create! row.to_hash
        end
    end    
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |product|
                csv << product.attributes.values_at(*column_names)
            end
        end
    end
    
end