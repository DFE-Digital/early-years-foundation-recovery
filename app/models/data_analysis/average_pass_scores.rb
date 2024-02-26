module DataAnalysis
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

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        if Rails.application.migrated_answers?
          Assessment.passed.group(:training_module).average(:score).map do |module_name, score|
            {
              module_name: module_name,
              pass_score: score,
            }
          end
        else
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
end
