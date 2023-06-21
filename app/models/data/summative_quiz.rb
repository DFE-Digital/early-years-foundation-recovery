module Data
  class SummativeQuiz
    class << self
      # @param attribute [Symbol]
      # @return [Hash{Symbol => Hash{Symbol => Numeric}}]
      def attribute_pass_percentage(attribute)
        grouped_assessments = user_summative_assessments.group(attribute).count

        grouped_assessments.transform_values do |count|
          pass_count = user_passed_assessments
          .where(attribute => grouped_assessments.key(count)).count

          pass_percentage = pass_count / count.to_f
          fail_percentage = 1 - pass_percentage

          { pass_percentage: pass_percentage, pass_count: pass_count, fail_percentage: fail_percentage, fail_count: count - pass_count }
        end
      end

    private

      # @return [ActiveRecord::Relation]
      def user_summative_assessments
        User.with_assessments.merge(UserAssessment.summative)
      end

      # @return [ActiveRecord::Relation]
      def user_passed_assessments
        User.with_assessments.merge(UserAssessment.summative.passes)
      end
    end
  end
end
