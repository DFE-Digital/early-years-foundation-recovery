class CoercionDecorator
  def call(input)
    @call ||= format_input(input)
  end

private

  def format_input(input)
    if input.is_a?(ActiveRecord::Relation)
      input
    else
      input.each do |key, value|
        input[key] = if value.is_a?(Array)
                       value.map { |element| format_value(key, element) }
                     else
                       format_value(key, value)
                     end
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

  def format_percentage(element)
    "#{(element * 100).round(2)}%"
  end

  def format_datetime(element)
    element.strftime('%Y-%m-%d %H:%M:%S')
  end
end
