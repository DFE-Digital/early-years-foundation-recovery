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
    def to_csv(coercion_decorator)
      CSV.generate(headers: true) do |csv|
        csv << column_names
        case dashboard
        when Array
          formatted = coercion_decorator.call(dashboard)
          formatted.each { |row| csv << row.values }
        when ActiveRecord::Relation
          batch_size = 1000
          formatted_batch = coercion_decorator.call(dashboard.limit(batch_size))

            dashboard.find_each(batch_size: 1_000) do |record|
              formatted = formatted_batch.find { |formatted_row| formatted_row["id"] == record.id }
              csv << (formatted.values_at(*record.dashboard_attributes.keys))
            end
        end
    end
  end

    # @return [Hash{Symbol => Array}] Structure used for the coercion of values for dashboard
    def data_hash
      Hash.new { |hash, key| hash[key] = [] }
    end
  end

  included do
    # Timestamps in the format "2023-01-11 12:52:22"
    # @return [Hash] coerce attributes prior to export
    def dashboard_attributes
      data_attributes.dup
    end

  private

    # @return [Hash] default to database fields
    def data_attributes
      attributes
    end
  end
end
