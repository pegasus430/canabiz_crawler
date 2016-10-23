class User < ActiveRecord::Base
    
    validates :username, presence: true, uniqueness: { case_sensitive: false }, length: {minimum: 1, maximum: 25}
    has_secure_password
end