module Data
    class SettingPassRate
    
      include Percentage

    def self.to_csv
        headers = ['Setting', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
        data = new.setting_pass_percentage.map do |setting_type, percentages|
          [setting_type, percentages[:pass], percentages[:pass_count], percentages[:fail], percentages[:fail_count]]
        end
        CSV.generate do |csv|
          csv << headers
  
          data.each do |row|
            csv << row
          end
        end
        format_csv(csv)
      end


    def setting_pass_percentage
        SummativeQuiz.attribute_pass_percentage(:setting_type)
    end

end
end