require "rails_helper"

describe User do
  describe "validations" do
    subject { create(:user) }

    it { is_expected.to validate_presence_of(:slack_id) }
    it { is_expected.to validate_uniqueness_of(:slack_id) }
  end

  describe "associations" do
    it { is_expected.to have_many(:turnip_price_records) }
  end
end
