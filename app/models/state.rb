class State < ActiveRecord::Base
    
    #relationships
    has_many :article_states
    has_many :articles, through: :article_states
    
    has_many :user_states
    has_many :users, through: :user_states 
    
    has_many :dispensaries
    has_many :vendors
    has_many :products
    
    #validations
    validates :name, presence: true, length: {minimum: 1, maximum: 50}
    validates :abbreviation, presence: true, length: {minimum: 1, maximum: 3}
    validates_uniqueness_of :name
    validates_uniqueness_of :abbreviation
    
    #friendly url
    extend FriendlyId
    friendly_id :name, use: :slugged
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            State.create! row.to_hash
        end
    end    
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |state|
                csv << state.attributes.values_at(*column_names)
            end
        end
    end
    
end