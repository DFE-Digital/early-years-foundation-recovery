module Data
  class SettingPassRate
    include ToCsv

    # @return [Array<String>]
    def self.column_names
      ['Setting', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
    end

    # @return [?] 
    def self.dashboard
      SummativeQuiz.attribute_pass_percentage(:setting_type).map do |setting_type, percentages|
        percentage[:type] = setting_type
      end
    end

      
    end
end
