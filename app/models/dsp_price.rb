class DspPrice < ActiveRecord::Base
    
    #relations
    belongs_to :dispensary_source_product#, inverse_of: :dsp_prices
    validates :price, numericality: {greater_than_or_equal_to: 0.01}
    
    #validations - no duplicate units per dispensary source product
    validates_uniqueness_of :unit, :scope => :dispensary_source_product 
    
    #set the display order
    before_validation :set_display_order
    
    UNIT_PRICES_OPTIONS = [:"Each", :"Half Gram", :"Gram", :"Bulk", :"2 Grams", :"Eighth", :"4 Grams", 
    :"Quarter Ounce", :"Half Ounce", :"Ounce", :"10mg", :"20mg", :"30mg", :"32mg", :"50mg", :"75mg", :"80mg", 
    :"85mg", :"90mg", :"100mg", :"125mg", :"130mg", :"0.25g", :"300mg", :".38g", :"400mg", :"500mg", :".7g", 
    :"750mg", :".75g", :".8g", :"1000mg", :"1050mg", :"1.5g", :"1.8g", :"2.5g", :"1oz, 100mg", :"2oz", 
    :"10mg CBD, 10mg THC", :"20mg CBD ,20mg THC", :"40mg CBD, 100mg THC", :"50mg CBD", :"50mg CBD, 50mg THC", 
    :"90mg CBD, 90mg THC", :"100 mg CBD, 2mg THC", :"100mg CBD, 2mg THC", :"100mg CBD, 20mg THC", 
    :"100mg CBD, 100mg THC", :"120mg CBD, 24mg THC", :"146mg CBD, 4mg THC", :"150mg CBD, 10mg THC", 
    :"175mg CBD", :"182mg CBD, 18mg THC", :"210mg CBD", :"250mg CBD, 50mg THC", :"50mg THC", 
    :"50mg THC, 50mg CBD", :"74.3mg THC, 1oz", :"100mg THC, 33mg CBD", :"100mg THC; 100mg CBD", 
    :"300mg THC, 300mg CBD", :"100mg total; 60mg THC, 20mg CBD", :"2 pack, 0.75g each", 
    :"10 Pack, 165mg CBD, 35mg THC", :"15 pack, 75mg THC, 45mg CBD", :"5ml, 75mg"]
    
    enum unit: UNIT_PRICES_OPTIONS
    
    DISPLAYS = { 
      "Each" => 0,
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

    def set_display_order
        if self.unit.present? && DISPLAYS.has_key?(self.unit)
            self.display_order = DISPLAYS[self.unit]
        else 
            puts "need to add the following value to displays map: " + self.unit.to_s
        end
    end
end