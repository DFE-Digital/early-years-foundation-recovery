module Data
  class SummativeQuiz
    
    class << self
      include Percentage

  

  


      def attribute_pass_percentage(attribute)
        grouped_assessments = user_summative_assessments.group(attribute).count

        grouped_assessments.transform_values do |count|
          pass_count = user_passed_assessments
          .where(attribute => grouped_assessments.key(count)).count

          pass_percentage = calculate_percentage(pass_count, count)
          fail_percentage = 100 - pass_percentage

          { pass: pass_percentage, pass_count: pass_count, fail: fail_percentage, fail_count: count - pass_count }
        end
      end

    private
      def user_summative_assessments
        User.with_assessments.merge(UserAssessment.summative)
      end

      def user_passed_assessments
        User.with_assessments.merge(UserAssessment.summative.passes)
      end

    end
  end
end
