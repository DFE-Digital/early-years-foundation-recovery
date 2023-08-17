class CoercionDecorator
  # @param input [Hash]
  # @return [Hash]
  def call(input)
    input.each { |key, value| input[key] = format_value(key, value) }
  end

private

  # @param key [Symbol]
  # @param value [Mixed]
  # @return [Mixed]
  def format_value(key, value)
    if value.is_a?(Time) || value.is_a?(DateTime)
      as_strftime(value)
    elsif key.to_s.ends_with?('percentage')
      as_percentage(value)
    else
      value
    end
  end

  # @param value [Numeric]
  # @return [String]
  def as_percentage(value)
    "#{(value * 100).round(2)}%"
  end

  # @param value [Time, DateTime]
  # @return [String]
  def as_strftime(value)
    value.strftime('%Y-%m-%d %H:%M:%S')
  end
end
