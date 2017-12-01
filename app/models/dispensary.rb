class Dispensary < ActiveRecord::Base

    #has_many :dispensary_photos --> not using right now
    
    belongs_to :state
    validates :name, presence: true, length: {minimum: 1, maximum: 300}
    
    #many to many with dispensary sources
    has_many :dispensary_sources
    has_many :sources, through: :dispensary_sources
    
    #geocode location
    geocoded_by :location
    after_validation :geocode
    
    #friendly url
    extend FriendlyId
    friendly_id :name, use: :slugged
    
    #photo aws storage
    mount_uploader :image, PhotoUploader
    
    #import CSV file
    def self.import_via_csv(file)
        CSV.foreach(file.path, headers: true) do |row|
            Dispensary.create! row.to_hash
        end
    end
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |dispensary|
                csv << dispensary.attributes.values_at(*column_names)
            end
        end
    end
    
    #FOR SEARCHING
    if Rails.env.production? 
        include Elasticsearch::Model
        include Elasticsearch::Model::Callbacks
        
        settings index: { number_of_shards: 1 } do
            mappings dynamic: 'false' do
                indexes :name, analyzer: 'english'
                indexes :location, analyzer: 'english'
                #indexes :state.name, analyzer: 'english' --> should we create / use state_name string variable? 
            end
        end        
    end
    
    
    def self.search(query)
        __elasticsearch__.search(
            {
                query: {
                    multi_match: {
                        query: query,
                        fields: ['title^10', 'body']
                    }
                }
            }
        )
    end
    

    
    
end #end dispensary class