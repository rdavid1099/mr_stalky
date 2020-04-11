slack_tokens = Rails.env.test? ? {} : Rails.application.credentials.slack

SlackMsgr.configure do |config|
  config.verification_token = slack_tokens[:verification_token]
  config.client_secret      = slack_tokens[:client_secret]
  config.signing_secret     = slack_tokens[:signing_secret]
  config.access_tokens      = {
    bot: slack_tokens[:bot_access_token],
  }
end

Rails.application.configure do
  config.slack_msgr = SlackMsgr
end
