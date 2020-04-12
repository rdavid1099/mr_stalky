RSpec.configure do |config|
  config.before(:each, type: :controller) do
    allow_any_instance_of(SlackVerification).to receive(:signing_secret?).and_return(true)
  end
end
