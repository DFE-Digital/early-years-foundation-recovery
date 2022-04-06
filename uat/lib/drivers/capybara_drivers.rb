module Drivers
  # Capybara registration for all drivers
  class CapybaraDrivers
    def self.register_all
      Firefox.register
      Firefox.register_headless
      Chrome.register
      Chrome.register_headless
      Chrome.register_remote
    end

    def self.chosen_driver
      browser
    end

    def self.browser
      case ENV['BROWSER']
      when 'firefox' then :firefox
      when 'chrome' then :chrome
      when 'headless_chrome' then :headless_chrome
      when 'headless_firefox' then :headless_firefox
      when 'remote_chrome' then :remote_chrome
      else abort 'BROWSER variable needs to be set to something valid, or left alone'
      end
    end
  end
end
