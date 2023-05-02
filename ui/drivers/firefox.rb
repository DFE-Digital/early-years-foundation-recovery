module Drivers
  class Firefox
    # @return [Capybara]
    def self.all_drivers
      register
      register_remote
      register_headless
    end

    # @return [Selenium::WebDriver::Firefox::Options]
    def self.driver_options(headless: false)
      options = if headless
                  %w[
                    -headless
                    disable-extensions
                    disable-gpu
                    no-sandbox
                    window-size=1280,80
                  ]
                else
                  []
                end

      Selenium::WebDriver::Options.firefox(
        accept_insecure_certs: true,
        'moz:firefoxOptions': options,
      )
    end

    # @return [Capybara]
    def self.register
      Capybara.register_driver :firefox do |app|
        Capybara::Selenium::Driver.new(
          app,
          browser: :firefox,
          options: driver_options,
        )
      end
    end

    # @return [Capybara]
    def self.register_headless
      Capybara.register_driver :headless_firefox do |app|
        Capybara::Selenium::Driver.new(
          app,
          browser: :firefox,
          options: driver_options(headless: true),
        )
      end
    end

    # @return [Capybara]
    def self.register_remote
      Capybara.register_driver :standalone_firefox do |app|
        Capybara::Selenium::Driver.new(
          app,
          browser: :remote,
          url: "http://#{ENV.fetch('DRIVER', 'localhost:4442')}/wd/hub",
          options: driver_options,
        )
      end
    end
  end
end
