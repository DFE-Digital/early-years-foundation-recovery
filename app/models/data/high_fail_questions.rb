module Data
  class HighFailQuestions
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'Module',
          'Question',
          'Failure Rate Percentage',
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        high_fail_questions.map do |(module_name, question_name), fail_rate|
          {
            module_name: module_name,
            question_name: question_name,
            fail_rate_percentage: fail_rate,
          }
        end
      end

    private

      # @return [Hash{Array<String> => Integer}]
      def question_attempts
        if ENV['DISABLE_USER_ANSWER'].present?
          Response.summative.group(:training_module, :question_name).count
        else
          UserAnswer.summative.group(:module, :name).count
        end
      end

      # @return [Hash{Array<String> => Integer}]
      def question_failures
        if ENV['DISABLE_USER_ANSWER'].present?
          Response.summative.where(correct: false).group(:training_module, :question_name).count
        else
          UserAnswer.summative.where(correct: false).group(:module, :name).count
        end
      end

      # @return [Integer]
      def total_attempts
        question_attempts.values.sum
      end

      # @return [Hash{Symbol => Mixed}]
      def high_fail_questions
        average_fail_rate = question_failures.values.sum / total_attempts.to_f

        high_fail_questions = {}

        question_failures.each do |(module_name, question_name), fail_count|
          total_count = question_attempts[[module_name, question_name]]
          fail_rate = fail_count / total_count.to_f

          if fail_rate >= average_fail_rate
            high_fail_questions[[module_name, question_name]] = fail_rate
          end
        end

        { average: average_fail_rate }.merge(high_fail_questions)
      end
    end
  end
end
