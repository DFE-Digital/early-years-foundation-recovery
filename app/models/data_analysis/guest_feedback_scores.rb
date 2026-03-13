module DataAnalysis
  class GuestFeedbackScores
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        %w[
          visit_id
          question_name
          answers
          created_at
          updated_at
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        Response.where(user_id: nil, question_type: 'feedback')
                .order(:visit_id, :question_name)
                .map do |response|
          {
            visit_id: response.visit_id,
            question_name: response.question_name,
            answers: response.answers,
            created_at: response.created_at&.strftime('%Y-%m-%d %H:%M:%S'),
            updated_at: response.updated_at&.strftime('%Y-%m-%d %H:%M:%S'),
          }
        end
      end

    private

      # @return [CoercionDecorator]
      def decorator
        @decorator ||= CoercionDecorator.new
      end
    end
  end
end
