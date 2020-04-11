class MockSlackMsgr
  def chat(*args)
  end
end

RSpec.configure do |config|
  config.before(:each) do
    stub_configuration(:slack_msgr, MockSlackMsgr)
  end
end
