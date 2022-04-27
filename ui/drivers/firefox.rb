# Drivers module for driver related functionality
module Drivers
  # Firefox related drivers
  class Firefox
    # Registers all drivers in class
    #
    # @return [Capybara] result of invoking all the firefox drivers requested for registration
    def self.all_drivers
      register
      register_remote
      register_headless
    end

    # @return [Capybara]
    def self.register
      capabilities = Selenium::WebDriver::Remote::Capabilities.firefox
      capabilities['acceptInsecureCerts'] = true

      Capybara.register_driver :firefox do |app|
        Capybara::Selenium::Driver.new(app, browser: :firefox, capabilities: capabilities)
      end
    end

    # @return [Capybara]
    def self.register_headless
      Capybara.register_driver :headless_firefox do |app|
        options = Selenium::WebDriver::Firefox::Options.new
        options.headless! # added on https://github.com/SeleniumHQ/selenium/pull/4762

        Capybara::Selenium::Driver.new(app, browser: :firefox, browser_options: options)
      end
    end

    # @return [Capybara]
    def self.register_remote
      capabilities = Selenium::WebDriver::Remote::Capabilities.firefox
      capabilities['acceptInsecureCerts'] = true

      remote_url =
        case ENV['BASE_URL']
        when 'https://app:3000'
          'http://firefox:4444/wd/hub'
        else
          'http://localhost:4442/wd/hub'
        end

      Capybara.register_driver :standalone_firefox do |app|
        Capybara::Selenium::Driver.new(app, browser: :remote, url: remote_url, capabilities: capabilities)
      end
    end
  end
end
