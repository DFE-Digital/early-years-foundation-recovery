module Data
  class ConfidenceCheckScores
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'Module',
          'Question',
          'Response',
          'Count',
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        confidence_check_scores.map do |(module_name, question_name, response), count|
          {
            module_name: module_name,
            question_name: question_name,
            response: response,
            count: count,
          }
        end
      end
  
    private
  
      # @return [Hash{Array<String, String, String> => Integer}]
      def confidence_check_scores
        Response.confidence_check.group(:training_module, :question_name, :response).count
      end 
    end
  end
end