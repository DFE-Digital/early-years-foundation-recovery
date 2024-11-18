module DataAnalysis
  class ConfidenceCheckScoresForManagerOrLeaderOnly
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
      def dashboard
        confidence_check_scores.map do |(module_name, question_name, answers), count|
          {
            module_name: module_name,
            question_name: question_name,
            answers: answers,
            count: count,
          }
        end
      end

    private

      # @return [Hash{Array<String, String, String> => Integer}]
      def confidence_check_scores
        User.with_confidence_score.leader_or_manager_only.order(:question_name).group(:training_module, :question_name, :answers).count
      end
    end
  end
end
