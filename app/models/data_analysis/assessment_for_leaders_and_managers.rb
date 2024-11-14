module DataAnalysis
  class AssessmentForLeadersAndManagers
    include ToCsv

    class << self
      # @note Personally identifiable information must not be revealed
      # @return [Array<String>]
      def column_names
        %w[
          user_id
          training_module
          score
          passed
          started_at
          completed_at
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        filtered_assessment.select(*column_names).map do |user|
          decorator.call user.attributes.symbolize_keys.except(:id)
        end
      end

      # @param mod [Training::Module]
      # @return [Integer]
      def filtered_assessment
        User.with_assessments.leader_or_manager
      end

    private

      # @return [CoercionDecorator]
      def decorator
        @decorator ||= CoercionDecorator.new
      end
    end
  end
end
