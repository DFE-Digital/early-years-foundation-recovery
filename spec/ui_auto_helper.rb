require 'spec_helper'
require 'capybara'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'site_prism'
require 'site_prism/all_there'
require 'yaml'

def require_all(dir)
  Dir["#{File.expand_path(File.join(File.dirname(File.absolute_path(__FILE__)), dir))}/**/*.rb"].each do |file|
    require file
  end
end

# default driver if none chosen
ENV['BROWSER'] ||= 'chrome'
# default environment for tests
ENV['ENV'] ||= 'local'

current_dir = File.dirname(__FILE__ )
puts "The current test dir is: #{current_dir}"

helpers_dir = File.expand_path('../ui_automation/helpers/', current_dir).to_s
puts "ui test helpers dir is: #{helpers_dir}"
puts `ls -al`
puts `pwd`
puts File.join(helpers_dir, 'config').to_s

require File.join(helpers_dir, 'config')

require_all '../ui_automation/drivers'

# after loading all the driver classes register them all immediately.
Drivers::CapybaraDrivers.register_all

require_all '../ui_automation/sections'
require_all '../ui_automation/pages'

# Then tell Capybara to use your driver of choice
Capybara.configure do |config|
  config.default_driver = Drivers::CapybaraDrivers.chosen_driver
end
