class VendorState < ActiveRecord::Base
    belongs_to :vendor
    belongs_to :state
end