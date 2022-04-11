module Drivers
  class Firefox
    def self.all_drivers
      register
      register_remote
      register_headless
    end

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

        Capybara::Selenium::Driver.new(app, browser: :firefox, browser_options: options)
      end
    end

    # Only accessible inside Docker -----------
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
