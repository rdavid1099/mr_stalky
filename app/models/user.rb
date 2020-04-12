class User < ApplicationRecord
  has_many :turnip_price_records, dependent: :destroy

  validates :slack_id, uniqueness: true, presence: true
end
