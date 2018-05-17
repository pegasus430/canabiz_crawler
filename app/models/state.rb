class State < ActiveRecord::Base
    
    #scope
    scope :product_state, -> { where(product_state: true) }
    
    #relationships
    has_many :article_states
    has_many :articles, through: :article_states
    
    has_many :user_states
    has_many :users, through: :user_states 
    
    has_many :dispensaries
    
    has_many :vendor_states
    has_many :vendors, through: :vendor_states
    
    has_many :product_states
    has_many :products, through: :product_states
    
    #validations
    validates :name, presence: true, length: {minimum: 1, maximum: 50}
    validates :abbreviation, presence: true, length: {minimum: 1, maximum: 3}
    validates_uniqueness_of :name
    validates_uniqueness_of :abbreviation
    
    #friendly url
    extend FriendlyId
    friendly_id :name, use: :slugged
    
end