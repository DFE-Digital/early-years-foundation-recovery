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

def require_all_files_in_dir(dir_path)
  Dir[Pathname(__dir__).realpath.join(dir_path)].each(&method(:require))
end

require_all_files_in_dir('lib/drivers')

%w[sections pages].each do |component|
  require_all_files_in_dir("lib/#{component}/*")
end

Drivers::CapybaraDrivers.register_all

Capybara.configure do |config|
  config.default_driver = Drivers::CapybaraDrivers.chosen_driver
end
