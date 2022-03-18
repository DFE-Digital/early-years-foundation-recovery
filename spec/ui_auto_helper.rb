require 'spec_helper'
require 'capybara'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'site_prism'
require 'site_prism/all_there'
require 'yaml'
require 'require_all'

# default driver if none chosen
ENV['BROWSER'] ||= 'chrome'
# default environment for tests
ENV['ENV'] ||= 'local'

require_relative '../ui_automation/helpers/config_helper'
require_rel '../ui_automation/drivers'

# after loading all the driver classes register them all immediately.
Drivers::CapybaraDrivers.register_all

require_rel '../ui_automation/sections'
require_rel '../ui_automation/pages'


# Then tell Capybara to use your driver of choice
Capybara.configure do |config|
  config.default_driver = Drivers::CapybaraDrivers.chosen_driver
end
