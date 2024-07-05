module DataAnalysis
  class UserFeedbackScores
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'User ID',
          'Role',
          'Custom Role',
          'Setting',
          'Custom Setting',
          'Local Authority',
          'Years Experience',
          'Module',
          'Question',
          'Answers',
          'Created',
          'Updated',
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        User.with_feedback.order(:user_id, :question_name).select(*agreed_attributes).map do |user|
          decorator.call user.attributes.symbolize_keys.except(:id)
        end
      end

    private

      # @return [CoercionDecorator]
      def decorator
        @decorator ||= CoercionDecorator.new
      end

      # @note Personally identifiable information must not be revealed
      #
      # @return [Array<Symbol>]
      def agreed_attributes
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
    end
  end
end
