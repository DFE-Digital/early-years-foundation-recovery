module Drivers
  class Firefox
    # @return [Capybara]
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
      # https://developer.mozilla.org/en-US/docs/Web/WebDriver/Capabilities
      capabilities = Selenium::WebDriver::Remote::Capabilities.firefox
      capabilities['acceptInsecureCerts'] = true
      # https://wiki.mozilla.org/Firefox/CommandLineOptions
      capabilities['moz:firefoxOptions'] = {
        args: %w[
          -headless
          disable-extensions
          disable-gpu
          no-sandbox
          window-size=1280,800
        ],
      }

      Capybara.register_driver :headless_firefox do |app|
        Capybara::Selenium::Driver.new(app, browser: :firefox, capabilities: capabilities)
      end
    end

    # @return [Capybara]
    def self.register_remote
      capabilities = Selenium::WebDriver::Remote::Capabilities.firefox
      capabilities['acceptInsecureCerts'] = true
      driver = ENV.fetch('DRIVER', 'localhost:4442')

      Capybara.register_driver :standalone_firefox do |app|
        Capybara::Selenium::Driver.new(
          app,
          browser: :remote,
          url: "http://#{driver}/wd/hub",
          capabilities: capabilities,
        )
      end
    end
  end
end
