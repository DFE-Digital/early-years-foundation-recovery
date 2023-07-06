require 'csv'

module ToCsv
  extend ActiveSupport::Concern

  class_methods do
    # Returns an array of strings representing the column names for the data export
    # @return [Array<String>]
    def column_names
      super
    rescue NoMethodError
      raise NoMethodError, 'ToCsv.to_csv a column names method must be defined for bespoke data export models to serve as csv column headers'
    end

    # Returns an array of hashes representing the rows of data to be exported or an ActiveRecord::Relation
    # @return [ActiveRecord::Relation, Array<Hash{Symbol => Mixed}>]
    def dashboard
      all
    rescue NoMethodError
      raise NoMethodError, 'ToCsv.to_csv a dashboard method must be defined for bespoke data export models to serve as csv data'
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
