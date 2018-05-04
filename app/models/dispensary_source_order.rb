class DispensarySourceOrder < ActiveRecord::Base
    belongs_to :order
    belongs_to :dispensary_source
    has_many :product_items
    
    validates :dispensary_source_id, presence: true
    
    validates_uniqueness_of :order_id, :scope => :dispensary_source_id #no duplicate orders per dispensary
    
    def total_price
		product_items.map(&:total_price).sum	
	end

end