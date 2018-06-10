class DispensarySourceProduct < ActiveRecord::Base
    
    #scope
    scope :for_featured, -> { 
        product_ids = Product.where(:featured_product => true).pluck(:id)
        where("product_id IN (?)", product_ids)
    }
    
    #relations
    belongs_to :product, counter_cache: :dsp_count
    belongs_to :dispensary_source
    has_many :dsp_prices
    accepts_nested_attributes_for :dsp_prices, allow_destroy: true
    
    #validations
    validates :dispensary_source_id, presence: true
    validates_uniqueness_of :product_id, :scope => :dispensary_source_id #no duplicate products per dispensary
    
    #delete related DSPPrices
    before_destroy :delete_dsp_prices
    def delete_dsp_prices
       self.dsp_prices.destroy_all 
    end
end