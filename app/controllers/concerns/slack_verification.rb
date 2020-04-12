module SlackVerification
  extend ActiveSupport::Concern

  included do
    before_action :verify_signed_secret
  end

  def verify_signed_secret
    render nothing: true, status: :unauthorized unless signing_secret?
  end

  def signing_secret?
    signature = request.headers["X-Slack-Signature"]
    timestamp = request.headers["X-Slack-Request-Timestamp"]
    version   = signature.split("=").first
    body      = request.body.read

    # The request timestamp is more than five minutes from local time.
    # It could be a replay attack, so let's ignore it.
    return false if Time.zone.at(timestamp.to_i) < 5.minutes.ago

    signature == "#{version}=#{compute_hash_sha256(version, timestamp, body)}"
  end

  def compute_hash_sha256(version, timestamp, body)
    digest = OpenSSL::Digest::SHA256.new
    OpenSSL::HMAC.hexdigest(digest, SlackMsgr.configuration.signing_secret, "#{version}:#{timestamp}:#{body}")
  end
end
