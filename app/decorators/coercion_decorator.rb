class CoercionDecorator
  extend Dry::Initializer

  param :input, type: Types::Strict::Array.of(Types::Strict::Hash)

  # @return [Array<Hash>]
  def call
    input.each { |row| row.map { |key, value| row[key] = format_value(key, value) } }
  end

private

  # @param key [Symbol]
  # @param value [Mixed]
  # @return [Mixed]
  def format_value(key, value)
    if value.is_a?(Time) || value.is_a?(DateTime)
      format_datetime(value)
    elsif key.to_s.include?('percentage')
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
