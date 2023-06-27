class CoercionDecorator
  extend Dry::Initializer

  param :input, type: Types::Strict::Array.of(Types::Strict::Hash)

  def call
    # if input.is_a?(ActiveRecord::Relation)
    #   @input = input.to_a.map(&:attributes)
    # end
    input.each do |row|
      row.each do |key, value|
        row[key] = format_value(key, value)
      end
    end
    input
  end

  def format_value(key, value)
    if value.is_a?(Time)
      format_datetime(value)
    elsif key.to_s.include?('percentage')
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
