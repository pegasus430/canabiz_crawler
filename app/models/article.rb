class Article < ActiveRecord::Base
    
    # only showing articles for active sources
    scope :active_source, -> { 
        source_ids = Source.where(:active => true).pluck(:id)
        where("source_id IN (?)", source_ids)
    }
    
    #relationships
    has_many :article_categories
    has_many :categories, through: :article_categories

    has_many :article_states
    has_many :states, through: :article_states

    belongs_to :source
    
    #validations
    validates :title, presence: true, length: {minimum: 3, maximum: 300}
    validates_uniqueness_of :title
    validates_uniqueness_of :web_url
    
    #friendly url
    extend FriendlyId
    friendly_id :title, use: :slugged
    
    #photo aws storage
    mount_uploader :image, PhotoUploader
    
    #import CSV files
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            Article.create! row.to_hash
        end
    end
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |article|
                csv << article.attributes.values_at(*column_names)
            end
        end
    end
    
    #delete related article_categories and article_states on delete
    before_destroy :delete_relations
    def delete_relations
       self.article_categories.destroy_all 
       self.article_states.destroy_all
    end
end