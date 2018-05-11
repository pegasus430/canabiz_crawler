class Category < ActiveRecord::Base
    
    #scopes
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
    
    #delete related article_categories and user_categories on delete
    before_destroy :delete_relations
    def delete_relations
       self.article_categories.destroy_all
       self.user_categories.destroy_all
    end
end