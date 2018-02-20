class Category < ActiveRecord::Base
    
    #so I can just say Category.active in query
    scope :active, -> { where(active: true) }
    scope :news, -> { where(category_type: 'News') }
    scope :products, -> { where(category_type: 'Product') }
    
    #relationships
    has_many :article_categories
    has_many :articles, through: :article_categories 
    
    has_many :user_categories
    has_many :users, through: :user_categories 
    
    has_many :products 
    
    #validations
    validates :name, presence: true, length: { minimum: 3, maximum: 25 }
    validates_uniqueness_of :name
    
    #friendly url
    extend FriendlyId
    friendly_id :name, use: :slugged
    
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