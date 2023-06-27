require 'csv'

module ToCsv
  extend ActiveSupport::Concern

  class_methods do
    def dashboard
      all
    end

    # def column_names

    # end

    # @return [String]
    def to_csv(batch_size: 1_000)
      CSV.generate(headers: true) do |csv|
        csv << column_names

        unformatted =
          if dashboard.is_a? Array
            dashboard
          else
            dashboard.find_each(batch_size: batch_size).map(&:dashboard_attributes)
          end
        formatted = CoercionDecorator.new(unformatted).call
        formatted.each { |row| csv << row.values }
      end
    end
  end

  included do
    # @return [Hash] default to database fields
    def dashboard_attributes
      attributes
    end
  end
end
