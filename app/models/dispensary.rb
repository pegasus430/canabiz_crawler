class Dispensary < ActiveRecord::Base

    #has_many :dispensary_photos --> not using right now
    
    #scope for admin panel
    scope :has_admin, -> { where.not(admin_user_id: nil) }
    
    belongs_to :state
    validates :name, presence: true, length: {minimum: 1, maximum: 300}
    
    #many to many with dispensary sources
    has_many :dispensary_sources
    has_many :sources, through: :dispensary_sources
    
    has_many :orders
    
    #geocode location
    geocoded_by :location
    after_validation :geocode
    
    #friendly url
    extend FriendlyId
    friendly_id :name, use: :slugged
    
    #photo aws storage
    mount_uploader :image, PhotoUploader
    
    #import CSV file
    def self.import_via_csv(dispensaries)
        CSV.parse(dispensaries, :headers => true).each do |row|
            #change to update record if id matches
            disp_hash = row.to_hash
            dispensary = self.where(id: disp_hash["id"])
            
            if dispensary.present? 
                dispensary.first.update_attributes(disp_hash)
            else
                Dispensary.create! disp_hash
            end
            
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
    
    #delete relations
    before_destroy :delete_relations
    def delete_relations
       self.dispensary_sources.destroy_all
    end
    
    
end #end dispensary class