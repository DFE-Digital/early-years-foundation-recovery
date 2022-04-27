# Drivers module for driver related functionality
module Drivers
  # Chrome driver versions
  class Chrome
    # Registers all drivers in the current class
    #
    # @return [Capybara] result of invoking all the chrome drivers requested for registration
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
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
      capabilities['acceptInsecureCerts'] = true

      # options = Selenium::WebDriver::Chrome::Options.new
      # options.add_preference(:download, prompt_for_download: false, default_directory: '/tmp/downloads')
      # options.add_preference(:browser, set_download_behavior: { behavior: 'allow' })

      Capybara.register_driver :headless_chrome do |app|
        # options.add_argument('--disable-extensions')
        # options.add_argument('--disable-gpu')
        # options.add_argument('--disable-dev-shm-usage') # overcome limited resource problems - vital for ci
        # options.add_argument('--no-sandbox')
        # options.add_argument('--headless')
        # options.add_argument('--disable-gpu')
        # options.add_argument('--window-size=1280,800')

        # Capybara::Selenium::Driver.new(app, browser: :chrome, browser_options: options)
        Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: capabilities)
      end
    end

    # @return [Capybara]
    def self.register_remote
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
      capabilities['acceptInsecureCerts'] = true

      remote_url =
        case ENV['BASE_URL']
        when 'https://app:3000'
          'http://chrome:4444/wd/hub'
        else
          'http://localhost:4441/wd/hub'
        end

      Capybara.register_driver :standalone_chrome do |app|
        Capybara::Selenium::Driver.new(app, browser: :remote, url: remote_url, capabilities: capabilities)
      end
    end
  end
end
