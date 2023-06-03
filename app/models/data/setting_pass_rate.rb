module Data
  class SettingPassRate
    include ToCsv
    include Percentage

    def self.to_csv
      headers = ['Setting', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
      data = setting_pass_percentage.map do |setting_type, percentages|
        [setting_type, percentages[:pass], percentages[:pass_count], percentages[:fail], percentages[:fail_count]]
      end
      format_percentages(data)
      generate_csv(headers, data)
    end

    def self.setting_pass_percentage
      SummativeQuiz.attribute_pass_percentage(:setting_type)
    end
  end
end
