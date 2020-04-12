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
          blocks: [],
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

    it "responds to 'record' command" do
      text = "<@app_id> record 123"

      response = "Thank you, <@#{user.slack_id}>! Your price of 123 bells has been successfully recorded."

      expect(described_class.new(payload[:event].merge(text: text), user).handle_message).to eq(response)
    end

    it "responds to 'whatsup' command" do
      travel_to Time.use_zone("Pacific Time (US & Canada)") { Time.zone.at(1_515_449_522.000016) }

      user = create(
        :user,
        turnip_price_records: [create(:turnip_price_record, price: 123, date: "2018-01-08", time_period: 1)],
      )
      text = "<@app_id> whatsup"

      expect(described_class.new(payload[:event].merge(text: text), user).handle_message).to eq(true)
    end

    it "returns nil if whatsup mention has more than one word" do
      text = "<@app_id> whatsup friend"

      expect(described_class.new(payload[:event].merge(text: text), user).handle_message).to eq(nil)
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

  describe "#whatsup" do
    it "displays the top turnip prices recorded for that time period" do
      travel_to Time.use_zone("Pacific Time (US & Canada)") { Time.zone.at(1_515_449_522.000016) }

      user = create(
        :user,
        turnip_price_records: [create(:turnip_price_record, price: 123, date: "2018-01-08", time_period: 1)],
      )
      text = "<@app_id> whatsup"

      expect_any_instance_of(AppMentionService).to receive(:post_message)
        .with(
          channel: "C0LAN2Q65",
          text: "",
          blocks: [
            {
              type: "section",
              text: {
                text: "The *top* turnip prices recorded this time period",
                type: "mrkdwn",
              },
              fields: [
                {
                  type: "mrkdwn",
                  text: "*User*",
                },
                {
                  type: "mrkdwn",
                  text: "*Bells*",
                },
                {
                  type: "mrkdwn",
                  text: "<@#{user.slack_id}>",
                },
                {
                  type: "plain_text",
                  text: "123",
                },
              ],
            },
          ],
        )
        .and_return({ ok: true })

      service = described_class.new(payload[:event].merge(text: text), user)
      service.whatsup

      expect(service.respond).to eq(true)
    end

    it "returns message if there are not any recorded turnip prices in the current time period" do
      user = create(
        :user,
        turnip_price_records: [create(:turnip_price_record, price: 123, date: "2018-01-08", time_period: 1)],
      )
      text = "<@app_id> whatsup"

      expect_any_instance_of(AppMentionService).to receive(:post_message)
        .with(
          channel: "C0LAN2Q65",
          text: "I don't have any turnip prices at this time. " \
            "Please type `@MrStalky record <price>` to record your turnip prices.",
          blocks: [],
        )
        .and_return({ ok: true })

      service = described_class.new(payload[:event].merge(text: text), user)

      service.whatsup

      expect(service.respond).to eq(true)
    end
  end
end
