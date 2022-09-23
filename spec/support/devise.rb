RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
end

# OPTIMIZE: I18n load order in specs as a result of custom Govspeak extensions.
# Ensure our custom translations are used (config/locales/devise.en.yml)
# because Devise is appending its defaults to I18n.load_path in the test suite.
I18n.load_path += Dir[Rails.root.join('config/locales/devise.en.yml')]
