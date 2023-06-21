class CoercionDecorator
  extend Dry::Initializer

  param :input

  class << self
    def call(input)
      input.each do |key, value|
        if value.is_a?(Array)
          input[key] = value.map { |element| format_value(key, element) }
        else
          format_value(key, value)
        end
      end
    end

    def format_value(key, value)
      if value.is_a?(Time)
        format_datetime(value)
      elsif key.to_s.ends_with?('percentage')
        format_percentage(value)
      else
        value
      end
    end

private

    def format_percentage(element)
      "#{(element * 100).round(2)}%"
    end

    def format_datetime(element)
      element.strftime('%Y-%m-%d %H:%M:%S')
    end
end
end
