class DispensarySourceProduct < ActiveRecord::Base
    belongs_to :product, counter_cache: :dsp_count
    belongs_to :dispensary_source
    has_many :dsp_prices
    
    validates :dispensary_source_id, presence: true
    
    validates_uniqueness_of :product_id, :scope => :dispensary_source_id #no duplicate products per dispensary
    
    #photo aws storage
    mount_uploader :image, PhotoUploader
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            DispensarySourceProduct.create! row.to_hash
        end
    end
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |dispensarySourceProduct|
                csv << dispensarySourceProduct.attributes.values_at(*column_names)
            end
        end
    end
    
    #delete related DSPPrices
    before_destroy :delete_dsp_prices
    def delete_dsp_prices
       self.dsp_prices.destroy_all 
    end
end