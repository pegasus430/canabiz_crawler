class SourceHashtag < ActiveRecord::Base
    belongs_to :source
    belongs_to :hashtag
end