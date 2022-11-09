module Drivers
  class Chrome
    # @return [Capybara]
    def self.all_drivers
      register
      register_remote
      register_headless
    end

    # @return [Capybara]
    def self.register
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
      capabilities['acceptInsecureCerts'] = true

      Capybara.register_driver :chrome do |app|
        Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: capabilities)
      end
    end

    # @return [Capybara]
    def self.register_headless
      # https://chromedriver.chromium.org/capabilities
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
      capabilities['acceptInsecureCerts'] = true
      # https://peter.sh/experiments/chromium-command-line-switches
      capabilities['goog:chromeOptions'] = {
        args: %w[
          headless
          disable-extensions
          disable-gpu
          no-sandbox
          window-size=1280,800
        ],
      }

      Capybara.register_driver :headless_chrome do |app|
        Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: capabilities)
      end
    end

    # @return [Capybara]
    def self.register_remote
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
      capabilities['acceptInsecureCerts'] = true
      driver = ENV.fetch('DRIVER', 'localhost:4441')

      Capybara.register_driver :standalone_chrome do |app|
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
