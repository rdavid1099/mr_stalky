require "rails_helper"

describe AppMentionService do
  let(:payload) do
    {
      token: "ZZZZZZWSxiZZZ2yIvs3peJ",
      team_id: "T061EG9R6",
      api_app_id: "A0MDYCDME",
      event: {
        type: "app_mention",
          user: "U061F7AUR",
          text: "<@U0LAN0Z89> whatsup",
          ts: "1515449522.000016",
          channel: "C0LAN2Q65",
          event_ts: "1515449522000016",
      },
      type: "event_callback",
      event_id: "Ev0LAN670R",
      event_time: 1_515_449_522_000_016,
      authed_users: [
        "U0LAN0Z89",
      ],
    }.to_json
  end

  describe ".respond" do
    subject { described_class.new(payload).respond }

    it "responds to a mention using SlackMsgr" do
      expect_any_instance_of(AppMentionService).to receive(:post_message)
        .with(
          channel: "C0LAN2Q65",
          text: "STALKS!",
        )
        .and_return({ ok: true })

      expect(subject).to eq(true)
    end
  end
end
