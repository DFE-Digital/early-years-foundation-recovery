require 'pry-byebug'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

require_relative './support/env'
require_relative './support/shared/with_user'
require_relative './support/shared/with_guest'

# Site Prism URL defaults to SSL in production
ENV['BASE_URL'] ||= 'http://localhost:3000'

# If no browser is chosen, then default to the following browser
ENV['BROWSER'] ||= 'firefox'

%w[drivers sections pages].each do |component|
  Dir[Pathname(__dir__).realpath.join("#{component}/*")].each(&method(:require))
end

require_relative './ui'

Drivers::CapybaraDrivers.register_all

Capybara.configure do |config|
  config.default_driver = Drivers::CapybaraDrivers.chosen_driver
end

Capybara.configure do |config|
  config.automatic_label_click = true
end
