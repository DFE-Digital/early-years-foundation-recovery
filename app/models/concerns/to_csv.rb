require 'csv'

module ToCsv
  extend ActiveSupport::Concern

  class ExportError < StandardError
  end

  class_methods do
    # @return [Array<String>]
    def dashboard_headers
      column_names
    rescue NoMethodError, NameError
      raise ExportError, "#{name}.dashboard_headers is required for bespoke models"
    end

    # @return [ActiveRecord::Relation, Array<Hash{Symbol => Mixed}>]
    def dashboard
      all
    rescue NoMethodError
      raise ExportError, "#{name}.dashboard is required for bespoke models"
    end

    # @param batch_size [Integer]
    # @return [String]
    def to_csv(batch_size: 1_000)
      CSV.generate(headers: true) do |csv|
        csv << dashboard_headers

        dashboard_rows =
          if dashboard.is_a?(Array)
            dashboard
          else
            dashboard.find_each(batch_size: batch_size).map(&:dashboard_row)
          end

        CoercionDecorator.new.call(dashboard_rows) { |row| csv << row.values }
      end
    end
  end

  included do
    # @return [Hash] undecorated row cells
    def dashboard_row
      attributes
    end
  end
end
