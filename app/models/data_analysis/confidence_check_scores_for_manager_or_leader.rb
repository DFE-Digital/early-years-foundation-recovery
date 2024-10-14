module DataAnalysis
  class ConfidenceCheckScoresForManagerOrLeader
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        %w[
          role_type
          role_type_other
          training_module
          question_name
          answers
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        User.with_confidence_score.leader_or_manager.order(:question_name).select(*column_names).map do |user|
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
