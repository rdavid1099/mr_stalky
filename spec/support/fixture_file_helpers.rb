module FixtureFileHelpers
  FIXTURES_DIRECTORY = Rails.root.join("spec/fixtures")

  def fixture_file(path)
    File.join(FIXTURES_DIRECTORY, path)
  end
end

RSpec.configure do |config|
  config.include FixtureFileHelpers
end
