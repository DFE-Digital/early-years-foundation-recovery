module Data
  class AveragePassScores
    include ToCsv
    def self.to_csv
      headers = ['Module', 'Average Pass Score']
      data = new.average_pass_scores.map { |module_name, average_score| [module_name, average_score] }
      generate_csv(headers, data)
    end

    def average_pass_scores
      UserAssessment.summative.passes.group(:module).average('CAST(score AS float)')
    end
  end
end
