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
      options = Selenium::WebDriver::Options.chrome(accept_insecure_certs: true)

      Capybara.register_driver :chrome do |app|
        Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
      end
    end

    # @return [Capybara]
    def self.register_headless
      # https://chromedriver.chromium.org/capabilities
      # https://peter.sh/experiments/chromium-command-line-switches

      options = Selenium::WebDriver::Options.chrome(
        accept_insecure_certs: true,
        'goog:chromeOptions': %w[
          headless
          disable-extensions
          disable-gpu
          no-sandbox
          window-size=1280,800
        ],
      )
      Capybara.register_driver :headless_chrome do |app|
        Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
      end
    end

    # @return [Capybara]
    def self.register_remote
      driver = ENV.fetch('DRIVER', 'localhost:4441')
      options = Selenium::WebDriver::Options.chrome(accept_insecure_certs: true)
      Capybara.register_driver :standalone_chrome do |app|
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
