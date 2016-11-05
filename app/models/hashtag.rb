class Hashtag < ActiveRecord::Base
    has_many :source_hashtags
    has_many :sources, through: :source_hashtags 
    
    validates :name, presence: true, length: { minimum: 3, maximum: 25 }
    validates_uniqueness_of :name
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            Hashtag.create! row.to_hash
        end
    end
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |hashtag|
                csv << hashtag.attributes.values_at(*column_names)
            end
        end
    end
end