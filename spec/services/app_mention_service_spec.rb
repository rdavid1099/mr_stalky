require "rails_helper"

describe AppMentionService do
  include SlackMentionPayload

  let(:user) { create(:user) }

  describe "#respond" do
    subject { described_class.new(payload[:event], user).respond }

    it "responds to a mention using SlackMsgr" do
      expect_any_instance_of(AppMentionService).to receive(:post_message)
        .with(
          channel: "C0LAN2Q65",
          text: "I'm sorry. I didn't quite get that. " \
            "Please type `@MrStalky help` for a list of the commands I understand.",
        )
        .and_return({ ok: true })

      expect(subject).to eq(true)
    end
  end

  describe "#handle_message" do
    it "returns does nothing if a valid command is not present in message" do
      text = "<@app_id> no commands"

      expect(described_class.new(payload[:event].merge(text: text), user).handle_message).to eq(nil)
    end

    it "records turnip price when proper command and syntax is passed" do
      text = "<@app_id> record 123"

      response = "Thank you, <@#{user.slack_id}>! Your price of 123 bells has been successfully recorded."

      expect(described_class.new(payload[:event].merge(text: text), user).handle_message).to eq(response)
      expect(user.turnip_price_records.last.price).to eq(123)
    end

    it "works regardless of casing" do
      text = "<@app_id> RECORD 123"

      response = "Thank you, <@#{user.slack_id}>! Your price of 123 bells has been successfully recorded."

      expect(described_class.new(payload[:event].merge(text: text), user).handle_message).to eq(response)
      expect(user.turnip_price_records.last.price).to eq(123)
    end
  end

  describe "#record" do
    it "records turnip price when proper command and syntax is passed" do
      text = "<@app_id> record 123"

      response = "Thank you, <@#{user.slack_id}>! Your price of 123 bells has been successfully recorded."

      expect(described_class.new(payload[:event].merge(text: text), user).record).to eq(response)
      expect(user.turnip_price_records.last.price).to eq(123)
    end

    it "replaces existing turnip price when proper command and syntax is passed" do
      text = "<@app_id> record 123"
      described_class.new(payload[:event].merge(text: text), user).record
      expect(user.turnip_price_records.count).to eq(1)
      expect(user.turnip_price_records.last.price).to eq(123)

      text = "<@app_id> record 130"
      described_class.new(payload[:event].merge(text: text), user).record

      expect(user.turnip_price_records.count).to eq(1)
      expect(user.turnip_price_records.last.price).to eq(130)
    end
  end
end
