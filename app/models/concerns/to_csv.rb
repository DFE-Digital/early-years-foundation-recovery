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
      puts "dashboard #{dashboard}"
      decorator = CoercionDecorator.new(dashboard)
      formatted = decorator.call
      CSV.generate(headers: true) do |csv|
        csv << column_names
        if dashboard.is_a?(Array)
          formatted.each { |record| csv << record }
        elsif dashboard.is_a?(Hash)
          rows = formatted.values.transpose
          rows.each { |row| csv << row }
        else
          dashboard.find_each(batch_size: 1_000) { |record| csv << record.dashboard_attributes.values }
      end

    end
    end
  end

  included do
    # Timestamps in the format "2023-01-11 12:52:22"
    # @return [Hash] coerce attributes prior to export
    def dashboard_attributes
      params = data_attributes.dup
    end

  private
    def data_attributes
      attributes
    end
  end
end
