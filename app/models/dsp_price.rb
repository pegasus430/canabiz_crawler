class DspPrice < ActiveRecord::Base
    belongs_to :dispensary_source_product
    validates :dispensary_source_product_id, presence: true
    validates :price, numericality: {greater_than_or_equal_to: 0.01}
    
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
    
    #set the display order
    before_validation :set_display_order
    def set_display_order
        
        displays = { 
            "Gram" => 1, "2 Grams" => 2, "Eighth" => 3, "Bulk" => 1, "Quarter Ounce" => 4,
            "Half Ounce" => 5, "Ounce" => 6, "Half Gram" => 0
        }
    
        if self.unit.present? && displays.has_key?(self.unit)
           self.display_order = displays[self.unit]
        else 
            puts "need to add the following value to displays map: " + self.unit
        end
    end
end