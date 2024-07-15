module DataAnalysis
  class UserFeedbackScores
    include ToCsv

    class << self
      # @note Personally identifiable information must not be revealed
      # @return [Array<String>]
      def column_names
        %w[
          user_id
          role_type
          role_type_other
          setting_type
          setting_type_other
          local_authority
          early_years_experience
          training_module
          question_name
          answers
          responses.created_at
          responses.updated_at
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        User.with_feedback.order(:user_id, :question_name).select(*column_names).map do |user|
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
