class User < ActiveRecord::Base
    
    validates :username, presence: true, uniqueness: { case_sensitive: false }, length: {minimum: 1, maximum: 25}
    has_secure_password
    
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