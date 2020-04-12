require "rails_helper"

describe TurnipPriceRecord do
  describe "validations" do
    subject { create(:turnip_price_record) }

    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:time_period) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end
end
