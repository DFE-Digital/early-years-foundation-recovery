require 'csv'

module ToCsv
  extend ActiveSupport::Concern

  class_methods do
    def dashboard
      all
    end

    # @return [String]
    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << column_names

        dashboard.find_each(batch_size: 1_000) { |record| csv << record.dashboard_attributes.values }
      end
    end

    # @param headers [Array<String>]
    # @param data [Array<Array<String>>]
    # @return [String]
    def generate_csv(headers, data)
      CSV.generate do |csv|
        csv << headers
        data.each do |row|
          csv << row
        end
      end
    end
  end

  included do
    # Timestamps in the format "2023-01-11 12:52:22"
    # @return [Hash] coerce attributes prior to export
    def dashboard_attributes
      params = data_attributes.dup

      params.each do |key, value|
        params[key] = value.strftime('%Y-%m-%d %H:%M:%S') if value.is_a?(Time)
      end
    end

  private

    # @return [Hash] default to database fields
    def data_attributes
      attributes
    end
  end
end
