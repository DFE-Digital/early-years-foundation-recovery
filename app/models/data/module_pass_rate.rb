module Data
  class ModulePassRate
    include ToCsv
    include Percentage

    def self.to_csv
      headers = ['Module', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count', 'Month']
      data = instance.module_pass_percentages_by_month.map do |module_name, percentages|
        [module_name, percentages[:pass], percentages[:pass_count], percentages[:fail], percentages[:fail_count], percentages[:month]]
      end
      format_percentages(data)
      generate_csv(headers, data)
    end

    def module_pass_percentages_by_month
      SummativeQuiz.attribute_pass_percentage(:module, :month)
    end
  end
end
