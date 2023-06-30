require 'csv'

module ToCsv
  extend ActiveSupport::Concern

  # Required interface:
  #
  # self.dashboard: Returns the data to be exported as a csv.
  # It should return an array of hashes, where each hash represents a row of data.
  #
  # self.column_names: Returns an array of strings representing the column names to be used as headers in the CSV file.

  class_methods do
    def dashboard
      all
    end

    # @return [String]
    # @param batch_size [Integer]
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
    # @return [Hash] default to database fields
    def dashboard_attributes
      attributes
    end
  end
end
