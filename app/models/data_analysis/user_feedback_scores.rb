module DataAnalysis
  class UserFeedbackScores
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'User ID',
          'Role',
          'Role Other',
          'Setting',
          'Setting Other',
          'Local Authority',
          'Years Experience',
          'Module',
          'Question',
          'Answers',
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        User.with_feedback.order(:user_id).select(*agreed_attributes).map do |user|
          user.attributes.symbolize_keys.except(:id)
        end
      end

    private

      # @note Personally identifiable information must not be revealed
      #
      # @return [Array<Symbol>]
      def agreed_attributes
        %i[
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
        ]
      end
    end
  end
end
