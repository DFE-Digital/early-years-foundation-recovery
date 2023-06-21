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
      data = data_hash
      UserAssessment.summative.passes.group(:module).average('CAST(score AS float)').to_a.each do |module_name, score|
        data[:module_name] << module_name
        data[:pass_score] << score
      end
      data
    end
  end
end
