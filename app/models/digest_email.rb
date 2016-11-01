class DigestEmail < ActiveRecord::Base
    
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            DigestEmail.create! row.to_hash
        end
    end
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |email|
                csv << email.attributes.values_at(*column_names)
            end
        end
    end
end