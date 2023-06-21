module Data
  class HighFailQuestions
    include ToCsv

    # @return [Array<String>]
    def self.column_names
      ['Module', 'Question', 'Failure Rate Percentage']
    end

    # @return [Hash{Symbol => Array}]
    def self.dashboard
      data = data_hash
      high_fail_questions.each do |(module_name, question_name), fail_rate|
        data[:module_name] << module_name
        data[:question_name] << question_name
        data[:fail_rate_percentage] << fail_rate
      end
      data
    end

    # @return [Hash{Symbol => Float, Array<Array<String, String>> => Float}]
    def self.high_fail_questions
      question_attempts = UserAnswer.summative.group(:module, :name).count
      question_failures = UserAnswer.summative.where(correct: false).group(:module, :name).count
      total_attempts = question_attempts.values.sum

      average_fail_rate = question_failures.values.sum / total_attempts.to_f

      high_fail_questions = {}

      question_failures.each do |(module_name, question_name), fail_count|
        total_count = question_attempts[[module_name, question_name]]
        fail_rate = fail_count / total_count

        if fail_rate > average_fail_rate
          high_fail_questions[[module_name, question_name]] = fail_rate.to_f
        end
      end

      { average: average_fail_rate }.merge(high_fail_questions)
    end
  end
end
