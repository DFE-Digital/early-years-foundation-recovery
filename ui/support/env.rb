require 'capybara'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'site_prism'
require 'site_prism/all_there'
require 'faker'
require 'dry/inflector'

Capybara.configure do |config|
  config.server_host = 'app'
  config.automatic_label_click = true
  config.default_max_wait_time = 10
end

Faker::Config.locale = 'en-GB'
