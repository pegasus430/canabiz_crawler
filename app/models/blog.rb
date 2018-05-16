class Blog < ActiveRecord::Base
    
    self.table_name = 'blog'
    
    #validations
    validates :title, presence: true, length: {minimum: 3, maximum: 300}
    validates_uniqueness_of :title
    validates :body, presence: true
    validates_length_of :body, :minimum => 300
    
    #friendly url
    extend FriendlyId
    friendly_id :title, use: :slugged
    
end