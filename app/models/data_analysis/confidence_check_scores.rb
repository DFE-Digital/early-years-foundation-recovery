module DataAnalysis
  class ConfidenceCheckScores
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        %w[
          Module
          Question
          Answers
          Count
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard(&block)
        results = []
        confidence_check_scores.each do |(module_name, question_name, answers), count|
          row = {
            module_name: module_name,
            question_name: question_name,
            answers: answers,
            count: count,
          }
          block ? yield(row) : results << row
        end
        block ? nil : results
      end

    private

      # @return [Hash{Array<String, String, String> => Integer}]
      def confidence_check_scores
        Response.confidence.order(:question_name).group(:training_module, :question_name, :answers).count
      end
    end
  end
end
