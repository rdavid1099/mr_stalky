class User < ApplicationRecord
  validates :slack_id, uniqueness: true, presence: true
end
