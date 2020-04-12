FactoryBot.define do
  factory :turnip_price_record do
    price { rand(400) }
    date { Faker::Date.between(from: 2.days.ago, to: Time.zone.today).strftime }
    time_period { rand(2) }
    user
  end
end
