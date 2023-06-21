module Data
  class SettingPassRate
    include ToCsv

    # @return [Array<String>]
    def self.column_names
      ['Setting', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
    end

    # @return [Hash{Symbol => Mixed}]
      def self.dashboard
        data = SummativeQuiz.attribute_pass_percentage(:setting_type).map do |setting_type, percentages|
          [setting_type] + percentages.values
        end
        keys = [ :type, :pass_percentage, :pass_count, :fail_percentage, :fail_count]
        keys.zip(data.transpose).to_h.transform_values(&:flatten)
      end
  end
end
