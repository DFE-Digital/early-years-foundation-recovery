module Percentage
  extend ActiveSupport::Concern

  class_methods do
    def calculate_percentage(numerator, denominator)
      return 0 if denominator.zero?

      (numerator.to_f / denominator) * 100
    end

    def format_percentages(data)
      data.map! do |element|
        case element
        when Array
          format_percentages(element)
        when Float
          "#{element.round(2)}%"
        else
          element
        end
      end
    end
  end
end
