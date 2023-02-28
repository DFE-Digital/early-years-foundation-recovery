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
      options = Selenium::WebDriver::Options.firefox(accept_insecure_certs: true)

      Capybara.register_driver :firefox do |app|
        Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
      end
    end

    # @return [Capybara]
    def self.register_headless
      options = Selenium::WebDriver::Options.firefox(accept_insecure_certs: true,
                                                     'moz:firefoxOptions': %w[
                                                       -headless
                                                       disable-extensions
                                                       disable-gpu
                                                       no-sandbox
                                                       window-size=1280,80
                                                     ])

      Capybara.register_driver :headless_firefox do |app|
        Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
      end
    end

    # @return [Capybara]
    def self.register_remote
      driver = ENV.fetch('DRIVER', 'localhost:4442')

      options = Selenium::WebDriver::Options.firefox(accept_insecure_certs: true)

      Capybara.register_driver :standalone_firefox do |app|
        Capybara::Selenium::Driver.new(
          app,
          browser: :remote,
          url: "http://#{driver}/wd/hub",
          options: options,
        )
      end
    end
  end
end
