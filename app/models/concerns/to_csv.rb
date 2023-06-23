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
    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << column_names

        case dashboard
        when Array
          formatted = CoercionDecorator.new(dashboard).call
          formatted.each { |row| csv << row.values }
        when ActiveRecord::Relation
          batch_size = 1000
          formatted_batch = CoercionDecorator.new(dashboard).call
          dashboard.find_each(batch_size: batch_size) do |record|
            formatted_batch << record.dashboard_attributes
              formatted_batch.each { |row| csv << row }
              formatted_batch = []
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
