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
        result = []

        SummativeQuiz.attribute_pass_percentage(:setting_type).each do |setting_type, percentages|
          pass_percentage = percentages[:pass_percentage]
          pass_count = percentages[:pass_count]
          fail_percentage = percentages[:fail_percentage]
          fail_count = percentages[:fail_count]

          result << {
            setting_type: setting_type,
            pass_percentage: pass_percentage,
            pass_count: pass_count,
            fail_percentage: fail_percentage,
            fail_count: fail_count,
          }
        end

        result
      end
  end
  end
end
