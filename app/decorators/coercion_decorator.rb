class CoercionDecorator
  # @param input [Hash, Array<Hash>]
  # @yield [Hash]
  def call(input)
    Array.wrap(input).to_enum.each { |row| yield reformat(row) }
  end

private

  # @param row [Hash]
  # @return [Hash]
  def reformat(row)
    row.each { |key, value| row[key] = format_value(key, value) }
  end

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
