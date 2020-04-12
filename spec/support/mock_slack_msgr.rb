class MockSlackMsgr
  def self.chat(*_args)
    { ok: true }
  end
end

RSpec.configure do |config|
  config.before(:each) do
    stub_configuration(:slack_msgr, MockSlackMsgr)
  end
end
