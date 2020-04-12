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

      post :create, params: payload({ event: { user: user.slack_id } })
      post_results = JSON.parse(response.body)

      expect(post_results["ok"]).to eq(true)
      expect(User.count).to eq(1)
    end
  end
end
