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
        ]
      }

      Capybara.register_driver :headless_firefox do |app|
        Capybara::Selenium::Driver.new(app, browser: :firefox, capabilities: capabilities)
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
        Capybara::Selenium::Driver.new(
          app,
          browser: :remote,
          url: remote_url,
          capabilities: capabilities)
      end
    end
  end
end
