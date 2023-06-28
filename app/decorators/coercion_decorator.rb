class CoercionDecorator
  extend Dry::Initializer

  param :input, type: Types::Strict::Array.of(Types::Strict::Hash)

  # @return [Array<Hash>]
  def call
    input.each { |row| row.each { |key, value| row[key] = format_value(key, value) } }
    input
  end

private

  # @param key [Symbol]
  # @param value [Mixed]
  # @return [Mixed]
  def format_value(key, value)
    if value.is_a?(Time)
      format_datetime(value)
    elsif key.to_s.include?('percentage')
      format_percentage(value)
    else
      value
    end
  end

  # @param element [Numeric]
  # @return [String]
  def format_percentage(element)
    "#{(element * 100).round(2)}%"
  end

  # @param element [Time]
  # @return [String]
  def format_datetime(element)
    element.strftime('%Y-%m-%d %H:%M:%S')
  end
end
