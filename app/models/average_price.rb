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
            # "4 Grams" 
            "Quarter Ounce" => 4,
            "Half Ounce" => 5, 
            "Ounce" => 6
        }
            
            # "10mg"
            # "10mg CBD, 10mg THC"
            # "20mg"
            # "20mg CBD ,20mg THC"
            # "30mg"
            # "32mg"
            # "40mg CBD, 100mg TH"
            # "50mg"
            # "50mg THC"
            # "50mg CBD"
            # "50mg CBD, 50mg THC"
            # "74.3mg THC, 1oz"
            # "75mg"
            # "80mg" => 0, 
            # "85mg"
            # "90mg" => 1,
            # "90mg CBD, 90mg THC"
            # "100mg" => 2,
            # "100 mg CBD, 2mg THC"
            # "100mg CBD, 2mg THC"
            # "100mg CBD, 20mg THC"
            # "100mg CBD, 100mg THC"
            # "100mg total; 60mg THC, 20mg CBD"
            # "120mg CBD, 24mg THC"
            # "130mg"
            # "146mg CBD, 4mg THC"
            # "175mg CBD"
            # "182mg CBD, 18mg THC"
            # "210mg CBD"
            # "250mg CBD, 50mg THC"
            # "300mg"
            # "100mg THC, 33mg CBD"
            # "100mg THC; 100mg CBD"
            # "300mg THC, 300mg CBD"
            # "100mg total; 60mg THC, 20mg CBD"
            # "0.25g"
            # ".38g" => 1,
            # "500mg"
            # ".7g" => 1,
            # "750mg"
            # ".75g"
            # ".8g"
            # "1000mg"
            # "1050mg" 
            # "1.5g"
            # "1.8g" => 2,
            # "2.5g"
            # "1oz, 100mg"
            # "2oz"
            # "2 pack, 0.75g each"
            # "10 Pack, 165mg CBD, 35mg THC"
            # "15 pack, 75mg THC, 45mg CBD"
            
            # "135mg CBD, 9mg THC"
            
            # "150mg CBD, 10mg THC"
            # "10mg CBD, 10mg THC"
            # "50mg THC, 50mg CBD"
            # "100mg CBD, 100mg THC"
            # "5ml, 75mg"
            # "400mg"
            # "125mg"
    
        if self.average_price_unit.present? && displays.has_key?(self.average_price_unit)
           self.display_order = displays[self.average_price_unit]
        else 
            # should i set a default value? - yes
            self.display_order = 99
            puts "need to add the following value to displays map: " + self.average_price_unit
        end
    end
    
end