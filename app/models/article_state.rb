class ArticleState < ActiveRecord::Base
    belongs_to :article
    belongs_to :state
    validates :article_id, presence: true
    validates :state_id, presence: true
end