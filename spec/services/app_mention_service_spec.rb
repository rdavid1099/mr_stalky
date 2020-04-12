require "rails_helper"

describe AppMentionService do
  include SlackMentionPayload

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
