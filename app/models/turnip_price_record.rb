class TurnipPriceRecord < ApplicationRecord
  belongs_to :user

  validates :price, :date, :time_period, presence: true

  enum time_period: { am: 0, pm: 1 }
end
