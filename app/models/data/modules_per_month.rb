module Data
  class ModulesPerMonth
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'Month',
          'Module',
          'Pass Percentage',
          'Pass Count',
          'Fail Percentage',
          'Fail Count',
        ]
      end

      # @return [Array<Hash>]
      def dashboard
        assessments_by_module_by_month.flat_map do |month, by_module|
          by_module.flat_map do |mod_name, assessments|
            pass_fail = SummativeQuiz.pass_fail(total: assessments.count, pass: assessments.count(&:passed?))

            { month: month, module_name: mod_name, **pass_fail }
          end
        end
      end

    private

      # @return [Hash]
      def assessments_by_month
        UserAssessment.summative.group_by { |assessment| assessment.created_at.strftime('%B %Y') }
      end

     # @return [Hash]
      def assessments_by_module_by_month
        assessments_by_month.transform_values { |assessments| assessments.group_by(&:module) }
      end
    end
  end
end
