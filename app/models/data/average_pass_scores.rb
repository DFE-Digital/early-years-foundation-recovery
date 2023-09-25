module Data
  class AveragePassScores
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'Module',
          'Average Pass Score',
        ]
      end

      # TODO: Upcoming changes to UserAssessment will make this type coercion unnecessary
      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        UserAssessment.summative.passes.group(:module).average('CAST(score AS float)').map do |module_name, score|
          {
            module_name: module_name,
            pass_score: score,
          }
        end
      end
    end
  end
end
