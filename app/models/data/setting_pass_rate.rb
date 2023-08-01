module Data
  class SettingPassRate
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        ['Setting', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        SummativeQuiz.attribute_pass_percentage(:setting_type).map do |setting_type, percentages|
          { setting_type: setting_type }.merge(percentages)
        end
      end
  end
  end
end
