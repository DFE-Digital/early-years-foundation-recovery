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
      coercion_decorator = CoercionDecorator.new
      CSV.generate(headers: true) do |csv|
        csv << column_names

        # Primitive Ruby objects
        # Array could contain raw values, or Hashes accessed via record.values
        # if dashboard.is_a?(Array)
        #   # dashboard.each { |record| csv << record }
        #   dashboard.each { |record| csv << coercion_decorator.call(record) }
        # # ActiveRecord collection of models
        # else
        #   # dashboard.find_each(batch_size: 1_000) { |record| csv << record.dashboard_attributes.values }
        #   dashboard.find_each(batch_size: 1_000) { |record| csv << record.data_attributes }
        # end


        if ancestors.include?(ActiveRecord::Base)
          dashboard.find_each(batch_size: 1_000) { |record| csv << record.data_attributes }
        else
          dashboard.each { |record| csv << coercion_decorator.call(record) }
        end

      end
    end
  end

  included do
    # Timestamps in the format "2023-01-11 12:52:22"
    # @return [Hash] coerce attributes prior to export
    # def dashboard_attributes
    #   params = data_attributes.dup

    #   params.each do |key, value|
    #     params[key] = value.strftime('%Y-%m-%d %H:%M:%S') if value.is_a?(Time)
    #   end
    # end

  private

    # @return [Hash] default to database fields
    def data_attributes
      attributes
    end
  end
end
