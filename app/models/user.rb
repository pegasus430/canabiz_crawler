class User < ActiveRecord::Base
    
    validates :username, presence: true, uniqueness: { case_sensitive: false }, length: {minimum: 1, maximum: 25}
    has_secure_password
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            User.create! row.to_hash
        end
    end    
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |user|
                csv << user.attributes.values_at(*column_names)
            end
        end
    end    
end