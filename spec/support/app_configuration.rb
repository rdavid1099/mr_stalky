module AppConfiguration
  def stub_configuration(key, value)
    allow(Rails.configuration).to receive(key).and_return(value)
  end
end

RSpec.configure do |config|
  config.include AppConfiguration
end
