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
      puts "Starting #{name}.to_csv"
      decorator = CoercionDecorator.new

      CSV.generate(headers: true) do |csv|
        csv << dashboard_headers

        if dashboard.is_a?(Array)
          dashboard.to_enum.each do |record|
            csv << decorator.call(record).values
          end
        else
          dashboard.find_each(batch_size: batch_size) do |record|
            csv << decorator.call(record.dashboard_row).values
          end
        end
      end
    end
  end

  included do
    # @return [Hash]
    def dashboard_row
      attributes
    end
  end
end
