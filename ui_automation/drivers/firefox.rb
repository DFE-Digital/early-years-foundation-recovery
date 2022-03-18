# module drivers
module Drivers
  # Firefox driver
  class Firefox
    def self.register
      Capybara.register_driver :firefox do |app|
        browser = ENV.fetch('browser', 'firefox').to_sym
        Capybara::Selenium::Driver.new(app, browser: browser, desired_capabilities: {})
      end
    end
  end
end
