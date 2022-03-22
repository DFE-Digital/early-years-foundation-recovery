# frozen_string_literal: true

# module Driver
module Drivers
  # Chrome driver registration
  class Chrome
    def self.register
      Capybara.register_driver :chrome do |app|
        Capybara::Selenium::Driver.new(app, browser: :chrome)
      end
    end
  end
end
