class AppMentionService
  def self.respond(payload)
    new(payload).respond
  end

  attr_reader :payload

  def initialize(payload)
    @payload = JSON.parse(payload)
  end

  def respond
    slack_response = post_message(
      channel: payload["event"]["channel"],
      text: "STALKS!",
    )
    slack_response[:ok]
  end

  private

  def post_message(**opts)
    slack_msgr.chat(:post_message, opts)
  end

  def slack_msgr
    Rails.configuration.slack_msgr
  end
end
