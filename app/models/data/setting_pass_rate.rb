module Data
  class SettingPassRate
    include ToCsv

    # @return [Array<String>]
    def self.column_names
      ['Setting', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
    end

    # @return [Hash{Symbol => Array}]
    def self.dashboard
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
          fail_count: fail_count
        }
      end
    
      result
    end
  end
end