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

      remote_url =
        case ENV['BASE_URL']
        when 'https://app:3000', /london\.cloudapps\.digital/ # NB: remove regexp for workflows/qa.yml
          'http://chrome:4444/wd/hub'
        else
          'http://localhost:4441/wd/hub'
        end

      Capybara.register_driver :standalone_chrome do |app|
        Capybara::Selenium::Driver.new(
          app,
          browser: :remote,
          url: remote_url,
          capabilities: capabilities,
        )
      end
    end
  end
end
