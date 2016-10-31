class Category < ActiveRecord::Base
    has_many :article_categories
    has_many :articles, through: :article_categories 
    
    has_many :user_categories
    has_many :users, through: :user_categories 
    
    validates :name, presence: true, length: { minimum: 3, maximum: 25 }
    validates_uniqueness_of :name
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            Category.create! row.to_hash
        end
    end
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |category|
                csv << category.attributes.values_at(*column_names)
            end
        end
    end
end