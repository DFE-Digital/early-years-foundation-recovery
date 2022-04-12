module Drivers
  class Firefox
    # Registers all drivers in class
    #
    # @return [Capybara] result of invoking all the firefox drivers requested for registration
    def self.all_drivers
      register
      register_remote
      register_headless
    end

    # Registers a firefox driver
    #
    # @return [Capybara] the firefox driver
    def self.register
      Capybara.register_driver :firefox do |app|
        Capybara::Selenium::Driver.new(app, browser: :firefox)
      end
    end

    # Registers a headless firefox driver
    #
    # @return [Capybara] the headless firefox driver
    def self.register_headless
      Capybara.register_driver :headless_firefox do |app|
        options = Selenium::WebDriver::Firefox::Options.new
        options.headless! # added on https://github.com/SeleniumHQ/selenium/pull/4762

        Capybara::Selenium::Driver.new(app, browser: :firefox, browser_options: options)
      end
    end

    # Registers a remote firefox driver - Only accessible inside docker
    #
    # @return [Capybara] the remote firefox driver
    def self.register_remote
      firefox_capabilities = Selenium::WebDriver::Remote::Capabilities.firefox
      firefox_capabilities['acceptInsecureCerts'] = true
      remote_url = 'http://firefox:4444/wd/hub'
      Capybara.register_driver :standalone_firefox do |app|
        Capybara::Selenium::Driver.new(app, browser: :remote, url: remote_url, capabilities: firefox_capabilities)
      end
    end
  end
end
