require 'spec_helper'
require 'capybara'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'site_prism'
require 'site_prism/all_there'
require 'yaml'
require 'require_all'

require_relative '../ui_automation/helpers/config_helper'
require_relative '../ui_automation/drivers/capybara_drivers'

Drivers::CapybaraDrivers.register_all

require_rel '../ui_automation/sections'
require_rel '../ui_automation/pages'

# default driver if none chosen
ENV['BROWSER'] ||= 'chrome'
ENV['ENV'] ||= 'local'

p Helpers::ConfigHelper.config_file_contents('environment')

# Then tell Capybara to use the Driver you've just defined as its default driver
Capybara.configure do |config|
  config.default_driver = ENV['BROWSER'].to_sym
end
