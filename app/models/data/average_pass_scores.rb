module Data
  class AveragePassScores
    include ToCsv

    # @return [Array<String>]
    def self.column_names
      ['Module', 'Average Pass Score']
    end

    # TODO: Upcoming changes to UserAssessment will make this type coercion unnecessary
    # @return [Array<Array>]
    def self.dashboard
      UserAssessment.summative.passes.group(:module).average('CAST(score AS float)').to_a
    end
  end
end
