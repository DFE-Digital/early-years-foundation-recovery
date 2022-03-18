# frozen_string_literal: true

# module drivers
module Drivers
  # Capybara registration for all drivers
  class CapybaraDrivers
    def self.register_all
      Firefox.register
      Chrome.register
    end

    def self.chosen_driver
      browser
    end

    def self.browser
      case ENV['BROWSER']
      when 'firefox' then :firefox
      when 'chrome' then :chrome
      else abort 'BROWSER variable needs to be set to something valid, or left alone'
      end
    end
  end
end
