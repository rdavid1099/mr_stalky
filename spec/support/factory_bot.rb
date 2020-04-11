RSpec.configure do |config|
  require_relative "./fixture_file_helpers"
  FactoryBot::SyntaxRunner.include FixtureFileHelpers if defined?(FactoryBot)
  config.include FactoryBot::Syntax::Methods
end
