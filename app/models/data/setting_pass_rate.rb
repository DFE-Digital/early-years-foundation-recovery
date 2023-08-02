module Data
  class SettingPassRate
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'Setting',
          'Pass Percentage',
          'Pass Count',
          'Fail Percentage',
          'Fail Count',
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        SummativeQuiz.pass_rate(:setting_type).map do |setting_type, percentages|
          { setting_type: setting_type, **percentages }
        end
      end
    end
  end
end
