require 'csv'

module ToCsv
  extend ActiveSupport::Concern

  class ExportError < StandardError
  end

  class_methods do
    # @return [Array<String>] table headers
    def column_names
      super
    rescue NoMethodError
      raise ExportError, "#{name}.column_names is required for bespoke models"
    end

    # @return [ActiveRecord::Relation, Array<Hash{Symbol => Mixed}>] table rows
    def dashboard
      all
    rescue NoMethodError
      raise ExportError, "#{name}.dashboard is required for bespoke models"
    end

    # @param batch_size [Integer]
    # @return [String]
    def to_csv(batch_size: 1_000)
      CSV.generate(headers: true) do |csv|
        csv << column_names

        unformatted = dashboard.is_a?(Array) ? dashboard : dashboard.find_each(batch_size: batch_size).map(&:dashboard_attributes)
        formatted = CoercionDecorator.new(unformatted).call
        formatted.each { |row| csv << row.values }
      end
    end
  end

  included do
    # @return [Hash] row cells
    def dashboard_attributes
      attributes
    end
  end
end
