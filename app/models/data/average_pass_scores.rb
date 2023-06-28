module Data
  class AveragePassScores
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        ['Module', 'Average Pass Score']
      end

      # TODO: Upcoming changes to UserAssessment will make this type coercion unnecessary
      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        data = []
        UserAssessment.summative.passes.group(:module).average('CAST(score AS float)').to_a.each do |module_name, score|
          row = {
            module_name: module_name,
            pass_score: score,
          }
          data << row
        end
        data
      end
  end
  end
end
