class DispensarySourceProduct < ActiveRecord::Base
    belongs_to :product, counter_cache: :dsp_count
    belongs_to :dispensary_source
    has_many :dsp_prices
    
    validates :dispensary_source_id, presence: true
    validates_uniqueness_of :product_id, :scope => :dispensary_source_id #no duplicate products per dispensary
    
    #delete related DSPPrices
    before_destroy :delete_dsp_prices
    def delete_dsp_prices
       self.dsp_prices.destroy_all 
    end
end