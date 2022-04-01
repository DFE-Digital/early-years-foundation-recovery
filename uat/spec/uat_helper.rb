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

require 'capybara'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'site_prism'
require 'site_prism/all_there'

Capybara.register_driver :chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
  capabilities['acceptInsecureCerts'] = true

  Capybara::Selenium::Driver.new(app,
                                 browser: :remote,
                                 url: 'http://chrome:4444/wd/hub',
                                 capabilities: capabilities)
end

Capybara.register_driver :firefox do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.firefox
  capabilities['acceptInsecureCerts'] = true

  Capybara::Selenium::Driver.new(app,
                                 browser: :remote,
                                 url: 'http://firefox:4444/wd/hub',
                                 capabilities: capabilities)
end

%w[sections pages].each do |component|
  Dir[Pathname(__dir__).realpath.join("support/#{component}/*")].each(&method(:require))
end

Capybara.configure do |config|
  config.default_driver = ENV['BROWSER'].to_sym
end
