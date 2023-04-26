module Drivers
  class Chrome
    # @return [Capybara]
    def self.all_drivers
      register
      register_remote
      register_headless
    end

    # @return [Selenium::WebDriver::Chrome::Options]
    def self.driver_options(headless: false)
      options = if !headless
                  []
                else
                  %w[
                    headless
                    disable-extensions
                    disable-gpu
                    no-sandbox
                    window-size=1280,800
                  ]
                end

      Selenium::WebDriver::Options.chrome(
        accept_insecure_certs: true,
        'goog:chromeOptions': options,
      )
    end

    # @return [Capybara]
    def self.register
      Capybara.register_driver :chrome do |app|
        Capybara::Selenium::Driver.new(
          app,
          browser: :chrome,
          options: driver_options,
        )
      end
    end

    # @return [Capybara]
    def self.register_headless
      Capybara.register_driver :headless_chrome do |app|
        Capybara::Selenium::Driver.new(
          app,
          browser: :chrome,
          options: driver_options(headless: true),
        )
      end
    end

    # @return [Capybara]
    def self.register_remote
      Capybara.register_driver :standalone_chrome do |app|
        Capybara::Selenium::Driver.new(
          app,
          browser: :remote,
          url: "http://#{ENV.fetch('DRIVER', 'localhost:4441')}/wd/hub",
          options: driver_options,
        )
      end
    end
  end
end
