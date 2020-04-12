class TurnipPriceRecord < ApplicationRecord
  belongs_to :user

  validates :price, :date, :time_period, presence: true

  enum time_period: { am: 0, pm: 1 }

  scope :current_top_prices, -> do
    where(
      "date = ? AND time_period = ?",
      Time.use_zone("Pacific Time (US & Canada)") { Time.zone.today },
      Time.use_zone("Pacific Time (US & Canada)") { (Time.zone.now.strftime("%H").to_i >= 12 && 1) || 0 },
    ).order(price: :desc)
  end
end
