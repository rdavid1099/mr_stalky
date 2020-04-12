FactoryBot.define do
  factory :user do
    slack_id { Faker::Internet.password }
  end
end
