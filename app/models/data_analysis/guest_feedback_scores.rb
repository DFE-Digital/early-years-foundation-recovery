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
        Response.visitor.feedback.order(:visit_id, :question_name).select(*column_names).map do |user|
          decorator.call user.attributes.symbolize_keys.except(:id)
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
