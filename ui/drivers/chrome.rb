module Drivers
  class Chrome
    # Registers all drivers in the current class
    #
    # @return [Capybara] result of invoking all the chrome drivers requested for registration
    def self.all_drivers
      register
      register_remote
      register_headless
    end

    # Registers all drivers in class
    #
    # @return [Capybara] bare bones chrome driver
    def self.register
      Capybara.register_driver :chrome do |app|
        Capybara::Selenium::Driver.new(app, browser: :chrome)
      end
    end

    # Registers a headless chrome driver
    #
    # @return [Capybara] the headless chrome driver
    def self.register_headless
      options = Selenium::WebDriver::Chrome::Options.new
      # options.add_preference(:download, prompt_for_download: false, default_directory: '/tmp/downloads')

      options.add_preference(:browser, set_download_behavior: { behavior: 'allow' })
      Capybara.register_driver :headless_chrome do |app|
        options.add_argument('--disable-extensions')
        options.add_argument('--disable-gpu')
        options.add_argument('--disable-dev-shm-usage') # overcome limited resource problems - vital for ci
        options.add_argument('--no-sandbox')
        options.add_argument('--headless')
        options.add_argument('--disable-gpu')
        options.add_argument('--window-size=1280,800')

        Capybara::Selenium::Driver.new(app, browser: :chrome, browser_options: options)
      end
    end

    # Registers a remote firefox driver - Only accessible inside docker
    #
    # @return [Capybara] the remote chrome driver
    def self.register_remote
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
      capabilities['acceptInsecureCerts'] = true
      remote_url = 'http://chrome:4444/wd/hub'
      Capybara.register_driver :standalone_chrome do |app|
        Capybara::Selenium::Driver.new(app, browser: :remote, url: remote_url, capabilities: capabilities)
      end
    end
  end
end
