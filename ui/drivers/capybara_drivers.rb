module Drivers
  # Capybara registration for all drivers
  class CapybaraDrivers
    def self.register_all
      klasses = Drivers.constants.select { |klass| Drivers.const_get(klass).is_a?(Class) }
      klasses.delete_if { |score| score.match?(/CapybaraDrivers/) }
      klasses.each { |klass| "Drivers::#{klass}".constantize.send(:all_drivers) }
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
