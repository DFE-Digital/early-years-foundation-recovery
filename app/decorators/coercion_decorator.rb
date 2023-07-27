class CoercionDecorator
  # @param input [Hash, Array<Hash>]
  # @yield [Hash]
  def call(input)
    Array.wrap(input).to_enum.each { |row| yield coerce(row) }
  end

private

  # @param row [Hash]
  # @return [Hash]
  def coerce(row)
    row.each { |key, value| row[key] = format_value(key, value) }
  end

  # @param key [Symbol]
  # @param value [Mixed]
  # @return [Mixed]
  def format_value(key, value)
    if value.is_a?(Time) || value.is_a?(DateTime)
      format_datetime(value)
    elsif key.to_s.ends_with?('percentage')
      format_percentage(value)
    else
      value
    end
  end

  # @param value [Numeric]
  # @return [String]
  def format_percentage(value)
    "#{(value * 100).round(2)}%"
  end

  # @param value [Time, DateTime]
  # @return [String]
  def format_datetime(value)
    value.strftime('%Y-%m-%d %H:%M:%S')
  end
end
