module Drivers
  # Capybara registration for all drivers
  class CapybaraDrivers
    # Invoke the #all_drivers methods on each of the driver classes within the drivers directory.
    # @return [Array] Driver classes
    def self.register_all
      inflector = Dry::Inflector.new
      klasses = Drivers.constants.select { |klass| Drivers.const_get(klass).is_a?(Class) }
      klasses.delete_if { |score| score.match?(/CapybaraDrivers/) }
      klasses.each { |klass| inflector.constantize("Drivers::#{klass}").send(:all_drivers) }
    end

    # Get the current browser
    # @return [Symbol] the current browser
    def self.chosen_driver
      browser
    end

    # String to symbol mapping based on value of environment variable BROWSER
    # @return [Symbol] the chosen browser
    def self.browser
      case ENV['BROWSER']
      when 'firefox' then :firefox
      when 'chrome' then :chrome
      when 'headless_chrome' then :headless_chrome
      when 'headless_firefox' then :headless_firefox
      when 'standalone_chrome' then :standalone_chrome
      when 'standalone_firefox' then :standalone_firefox
      else abort 'BROWSER variable needs to be set to something valid, or left alone'
      end
    end
  end
end
