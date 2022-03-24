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

    def self.register_headless
      Capybara.register_driver :headless_firefox do |app|
        options = Selenium::WebDriver::Firefox::Options.new
        options.headless! # added on https://github.com/SeleniumHQ/selenium/pull/4762

        Capybara::Selenium::Driver.new app,
                                       browser: :firefox,
                                       browser_options: options
      end
    end
  end
end
