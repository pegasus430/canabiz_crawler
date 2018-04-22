class AveragePrice < ActiveRecord::Base
    
    #validations
    validates :average_price, numericality: {greater_than_or_equal_to: 0.01}
    
    #lookups
    belongs_to :product
    
    #import CSV file
    def self.import(file)
        CSV.foreach(file.path, headers: true) do |row|
            AveragePrice.create! row.to_hash
        end
    end    
    
    #export CSV file
    def self.to_csv
        CSV.generate do |csv|
            csv << column_names
            all.each do |average_price|
                values = average_price.attributes.values_at(*column_names)
                values += [average_price.product.name] if average_price.product
                csv << values
            end
        end
    end
    
    #set the display order
    before_validation :set_display_order
    def set_display_order
        
        displays = { 
            "Half Gram" => 0,
            "Half Grams" => 0,
            "Gram" => 1,
            "Bulk" => 1,
            "2 Grams" => 2, 
            "Eighth" => 3,
            "4 Grams" => 4,
            "Quarter Ounce" => 5,
            "Half Ounce" => 6, 
            "Ounce" => 7,
            
            "10mg" => 0,
            "20mg" => 1,
            "30mg" => 2,
            "32mg" => 3,
            "50mg" => 4,
            "75mg" => 5,
            "80mg" => 6, 
            "85mg" => 7,
            "90mg" => 8,
            "100mg" => 9,
            "125mg" => 10,
            "130mg" => 10,
            "0.25g" => 11,
            "300mg" => 12,
            ".38g" => 13,
            "400mg" => 14,
            "500mg" => 14,
            ".7g" => 15,
            "750mg" => 16,
            ".75g" => 17,
            ".8g" => 18,
            "1000mg" => 19,
            "1050mg" => 20,
            "1.5g" => 21,
            "1.8g" => 22,
            "2.5g" => 23,
            "1oz, 100mg" => 24,
            "2oz" => 25,
            
            "10mg CBD, 10mg THC" => 0,
            "20mg CBD ,20mg THC" => 1,
            "40mg CBD, 100mg THC" => 2,
            "50mg CBD" => 3,
            "50mg CBD, 50mg THC" => 4,
            "90mg CBD, 90mg THC" => 5,
            "100 mg CBD, 2mg THC" => 6,
            "100mg CBD, 2mg THC" => 7,
            "100mg CBD, 20mg THC" => 8,
            "100mg CBD, 100mg THC" => 9,
            "100mg total; 60mg THC, 20mg CBD" => 10,
            "120mg CBD, 24mg THC" => 11,
            "146mg CBD, 4mg THC" => 12,
            "150mg CBD, 10mg THC" => 13,
            "175mg CBD" => 14,
            "182mg CBD, 18mg THC" => 15,
            "210mg CBD" => 16,
            "250mg CBD, 50mg THC" => 17,
            "50mg THC" => 18,
            "50mg THC, 50mg CBD" => 19,
            "74.3mg THC, 1oz" => 20,
            "100mg THC, 33mg CBD" => 21,
            "100mg THC; 100mg CBD" => 22,
            "300mg THC, 300mg CBD" => 23,
            "100mg total; 60mg THC, 20mg CBD" => 24,
            
            "2 pack, 0.75g each" => 0,
            "10 Pack, 165mg CBD, 35mg THC" => 1,
            "15 pack, 75mg THC, 45mg CBD" => 2,
            "5ml, 75mg" => 3
        }
    
        if self.average_price_unit.present? && displays.has_key?(self.average_price_unit)
           self.display_order = displays[self.average_price_unit]
        else 
            # should i set a default value? - yes
            self.display_order = 99
            puts "need to add the following value to displays map: " + self.average_price_unit
        end
    end
    
end