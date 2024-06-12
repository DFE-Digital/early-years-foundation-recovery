module DataAnalysis
  class GuestFeedbackScores
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        %w[
          Guest
          Question
          Answers
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        Response.visitor.feedback.select(
          :visit_id,
          :question_name,
          :answers,
        ).map do |user|
          user.attributes.symbolize_keys.except(:id)
        end
      end
    end
  end
end
