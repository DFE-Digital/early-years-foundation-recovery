module Data
  class ModulesPerMonth
    include ToCsv

    # @return [Array<String>]
    def self.column_names
      ['Month', 'Module', 'Pass Percentage', 'Pass Count', 'Fail Percentage', 'Fail Count']
    end

    # @return [Hash{Symbol => Array}]
    def self.dashboard
      data = []
      modules_by_month.each do |month, module_data|
        module_data.each do |module_name, assessments|
          pass_count = assessments.count(&:passed?)
          total_count = assessments.size
          fail_count = total_count - pass_count

          pass_percentage = pass_count / total_count.to_f
          fail_percentage = 1 - pass_percentage

          row = {
            month: month,
            module_name: module_name,
            pass_percentage: pass_percentage,
            pass_count: pass_count,
            fail_percentage: fail_percentage,
            fail_count: fail_count,
          }
          data << row
        end
      end
      data
    end

    # @return [Hash{String => Hash{String => Array<UserAssessment>}}]
    def self.modules_by_month
      UserAssessment.summative.group_by { |assessment| assessment.created_at.strftime('%B %Y') }
                     .transform_values { |assessments_by_month| assessments_by_month.group_by(&:module) }
    end
  end
end
