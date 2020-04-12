require "rails_helper"

describe Api::MentionsController do
  include SlackMentionPayload

  describe "#create" do
    it "creates a user by slack_id passed in mention payload" do
      expect {
        post :create, params: payload
        post_results = JSON.parse(response.body)

        expect(post_results["ok"]).to eq(true)
      }.to change { User.count }.from(0).to(1)
    end

    it "does not create a user if slack_id already exists" do
      user = create(:user)

      post :create, params: payload({ event: { user: user.slack_id, text: "" } })
      post_results = JSON.parse(response.body)

      expect(post_results["ok"]).to eq(true)
      expect(User.count).to eq(1)
    end

    context "keyphrase 'record <turnip price>' is the event text" do
      let(:user) { create(:user) }
      let(:event) { { channel: "C0LAN2Q65", ts: "1586653062.002100", user: user.slack_id } }

      context "text contains exactly the app_id, the word 'record' and an integer" do
        before(:each) do
          expect_any_instance_of(AppMentionService).to receive(:post_message).with(
            channel: "C0LAN2Q65",
            text: "Thank you, <@#{user.slack_id}>! Your price of 123 bells has been successfully recorded.",
          )
            .and_return({ ok: true })
        end

        it "records the price passed in for the day and hour it came in" do
          post :create, params: payload({ event: event.merge({ text: "<@app_id> record 123" }) })
          post_results = JSON.parse(response.body)
          turnip_price_record = user.turnip_price_records.last

          expect(post_results["ok"]).to eq(true)
          expect(turnip_price_record.price).to eq(123)
          expect(turnip_price_record.date).to eq(Date.parse("2020-04-11"))
          expect(turnip_price_record.time_period).to eq("pm")
        end

        ["record   <@app_id>   123", "record...123, <@app_id>!", "123    record! <@app_id>"].each do |text|
          it "records the price for unconventional phrase '#{text}'" do
            post :create, params: payload({ event: event.merge({ text: text }) })
            post_results = JSON.parse(response.body)
            turnip_price_record = user.turnip_price_records.last

            expect(post_results["ok"]).to eq(true)
            expect(turnip_price_record.price).to eq(123)
            expect(turnip_price_record.date).to eq(Date.parse("2020-04-11"))
            expect(turnip_price_record.time_period).to eq("pm")
          end
        end
      end

      context "text does not contain exactly the app_id, the word 'record' and an integer" do
        before(:each) do
          expect_any_instance_of(AppMentionService).to receive(:post_message).with(
            channel: "C0LAN2Q65",
            text: "I'm sorry. I didn't quite get that. " \
                  "Please type `@MrStalky help` for a list of the commands I understand.",
          )
            .and_return({ ok: true })
        end

        ["<@app_id> record this 120", "120 bells record!  <@app_id>", "record <@app_id>"].each do |text|
          it "does not record and responds with error message when '#{text}' is passed in" do
            post :create, params: payload({ event: event.merge({ text: text }) })
            post_results = JSON.parse(response.body)

            expect(post_results["ok"]).to eq(true)
            expect(user.turnip_price_records.count).to eq(0)
          end
        end
      end
    end
  end
end
