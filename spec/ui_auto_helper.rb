require 'spec_helper'

require 'capybara'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'site_prism'
require 'site_prism/all_there'
require 'require_all'

require_rel '../ui_automation/sections'
require_rel '../ui_automation/pages'


Capybara.register_driver :site_prism do |app|
  browser = ENV.fetch('browser', 'firefox').to_sym
  Capybara::Selenium::Driver.new(app, browser: browser, desired_capabilities: {})
end

# Then tell Capybara to use the Driver you've just defined as its default driver
Capybara.configure do |config|
  config.default_driver = :site_prism
end
