class DspPrice < ActiveRecord::Base
    belongs_to :dispensary_source_product
    validates :dispensary_source_product_id, presence: true
    
    #no duplicate units per dispensary source product
    validates_uniqueness_of :unit, :scope => :dispensary_source_product 
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            DspProduct.create! row.to_hash
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
end