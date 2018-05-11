class User < ActiveRecord::Base
    
    #validations
    validates :username, presence: true, uniqueness: { case_sensitive: false }, length: {minimum: 1, maximum: 25}
    has_secure_password
    
    #relationships
    has_many :user_categories
    has_many :categories, through: :user_categories

    has_many :user_states
    has_many :states, through: :user_states
    
    has_many :user_sources
    has_many :sources, through: :user_sources
    
    has_many :articles, through: :categories
    has_many :articles, through: :states
    
    #friendly url
    extend FriendlyId
    friendly_id :username, use: :slugged
    
    #password reset token
    def generate_password_reset_token!
        update_attribute(:password_reset_token, SecureRandom.urlsafe_base64(48))  
    end
end