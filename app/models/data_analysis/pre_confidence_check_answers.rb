module DataAnalysis
  class PreConfidenceCheckAnswers
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        %w[
          user_id
          training_module
          question_type
          question_name
          answer
          created_at
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard(batch_size: 1000)
        return enum_for(:dashboard, batch_size: batch_size) unless block_given?

        confidence_check_answers.find_each(batch_size: batch_size) do |response|
          yield({
            user_id: response.user_id,
            training_module: response.training_module,
            question_type: response.question_type,
            question_name: response.question_name,
            answer: response.answers,
            created_at: response.created_at,
          })
        end
      end

    private

      # @return [Hash{Array<String, String, String> => Integer}]
      def confidence_check_answers
        Response.pre_and_post_confidence.order(:question_name)
      end
    end
  end
end
