module Data
  class SettingPassRate
    include ToCsv
    include Percentage

    def self.column_names
      ['Setting', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
    end

    def self.dashboard
      data = setting_pass_percentage.map do |setting_type, percentages|
        [setting_type, percentages[:pass], percentages[:pass_count], percentages[:fail], percentages[:fail_count]]
      end
      format_percentages(data)
    end

    # @return [Hash{Symbol => Hash{Symbol => Float, Integer}}]
    def self.setting_pass_percentage
      SummativeQuiz.attribute_pass_percentage(:setting_type)
    end
  end
end
