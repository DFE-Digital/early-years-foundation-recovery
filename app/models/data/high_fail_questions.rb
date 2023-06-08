module Data
  class HighFailQuestions
    include ToCsv
    include Percentage

    # @return [Array<String>]
    def self.column_names
      ['Module', 'Question', 'Failure Rate Percentage']
    end

    # @return [Array<Array<String>>]
    def self.dashboard
      data = high_fail_questions.map { |(module_name, question_name), fail_rate| [module_name, question_name, fail_rate] }
      format_percentages(data)
    end

    # @return [Hash{Symbol => Float, Array<Array<String, String>> => Float}]
    def self.high_fail_questions
      question_attempts = UserAnswer.summative.group(:module, :name).count
      question_failures = UserAnswer.summative.where(correct: false).group(:module, :name).count
      total_attempts = question_attempts.values.sum

      average_fail_rate = calculate_percentage(question_failures.values.sum, total_attempts)

      high_fail_questions = {}

      question_failures.each do |(module_name, question_name), fail_count|
        total_count = question_attempts[[module_name, question_name]]
        fail_rate = calculate_percentage(fail_count, total_count)

        if fail_rate > average_fail_rate
          high_fail_questions[[module_name, question_name]] = fail_rate
        end
      end

      { average: average_fail_rate }.merge(high_fail_questions)
    end
  end
end
