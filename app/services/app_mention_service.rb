class AppMentionService
  COMMANDS = %i[record whatsup].freeze

  attr_reader :event_params, :user

  def initialize(event_params, user)
    @event_params = event_params
    @user = user
  end

  def handle_message
    return unless command.present? && valid_command?

    send(command)
  end

  def respond
    slack_response = post_message(
      channel: event_params[:channel],
      text: response,
      blocks: blocks,
    )
    slack_response[:ok]
  end

  def record
    date = sanitized_timestamp.strftime("%Y-%m-%d")
    time_period = (sanitized_timestamp.strftime("%H").to_i >= 12 && 1) || 0
    turnip_price_record = user.turnip_price_records.find_or_initialize_by(date: date, time_period: time_period)
    turnip_price_record.price = stripped_text.first.to_i

    return unless turnip_price_record.save

    declare_response("Thank you, <@#{user.slack_id}>! " \
      "Your price of #{turnip_price_record.price} bells has been successfully recorded.")
  end

  def whatsup
    current_top_prices = TurnipPriceRecord.current_top_prices.limit(5)

    if current_top_prices.empty?
      return declare_response("I don't have any turnip prices at this time. " \
        "Please type `@MrStalky record <price>` to record your turnip prices.")
    end

    field_headers = [{ type: "mrkdwn", text: "*User*" }, { type: "mrkdwn", text: "*Bells*" }]
    fields = current_top_prices.reduce(field_headers) do |_result, price_record|
      field_headers << { type: "mrkdwn", text: "<@#{price_record.user.slack_id}>" }
      field_headers << { type: "plain_text", text: price_record.price.to_s }
    end

    declare_response("")

    add_to_blocks({
                    type: "section",
                    text: {
                      text: "The *top* turnip prices recorded this time period",
                      type: "mrkdwn",
                    },
                    fields: fields,
                  })

    true
  end

  private

  def valid_command?
    {
      record: (stripped_text.count == 1 && stripped_text.first.to_i.positive?),
      whatsup: stripped_text.count.zero?,
    }[command]
  end

  def command
    @command ||= COMMANDS.find do |command|
      sanitized_text.include?(command.to_s)
    end
  end

  def sanitized_timestamp
    Time.use_zone("Pacific Time (US & Canada)") { Time.zone.at(event_params[:ts].to_f) }
  end

  def sanitized_text
    event_params[:text].gsub(/\s*<[^()]*\>\s*/, " ").gsub(/[^0-9A-Za-z\s]/, "").downcase
  end

  def stripped_text
    sanitized_text.gsub(/\s*#{command}\s*/, "").split(" ").reject(&:empty?)
  end

  def post_message(**opts)
    slack_msgr.chat(:post_message, opts)
  end

  def slack_msgr
    Rails.configuration.slack_msgr
  end

  def add_to_blocks(block)
    blocks << block
  end

  def blocks
    @blocks ||= []
  end

  def declare_response(response)
    @response = response
  end

  def response
    @response ||= "I'm sorry. I didn't quite get that. " \
                  "Please type `@MrStalky help` for a list of the commands I understand."
  end
end
