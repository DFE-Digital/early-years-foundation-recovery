module Data
  class AveragePassScores
    include ToCsv

    # @return [Array<String>]
    def self.column_names
      ['Module', 'Average Pass Score']
    end

    # @return [Array<Array<String>>]
    def self.dashboard
      average_pass_scores.map { |module_name, average_score| [module_name, average_score] }
    end

    # @return [String]
    def self.to_csv
      generate_csv
    end

    # TODO: Upcoming changes to UserAssessment will make this type coercion unnecessary
    # @return [ActiveRecord::Result]
    def self.average_pass_scores
      UserAssessment.summative.passes.group(:module).average('CAST(score AS float)')
    end
  end
end
