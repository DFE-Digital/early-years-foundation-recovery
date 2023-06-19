class CoercionDecorator
    extend Dry::Initializer

    param :input

    def call
        input.each do |key, value|
            if value.is_a?(Array)
              formatted_values = value.map do |element|
                if value.is_a?(Time)
                  format_datetime(element)
                elsif key.to_s.ends_with?('percentage')
                  format_percentage(element)
                else
                  element
                end
              end
              input[key] = formatted_values
            elsif value.is_a?(Time)
              input[key] = format_datetime(value)
            elsif key.to_s.ends_with?('percentage')
              input[key] = format_percentage(value)
            end
          end
        end

    private
    def format_percentage(element)
        "#{element.round(2)}%"
    end

    def format_datetime(element)
        element.strftime('%Y-%m-%d %H:%M:%S')
    end
end