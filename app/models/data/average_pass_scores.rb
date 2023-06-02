module Data
    class AveragePassScores

            include Percentage
            def self.to_csv
                headers = ['Module', 'Average Pass Score']
                data = new.average_pass_scores.map { |module_name, average_score| [module_name, average_score] }
                CSV.generate do |csv|
                    csv << headers
            
                    data.each do |row|
                      csv << row
                    end
                  end
                end

        def average_pass_scores
            UserAssessment.summative.passes.group(:module).average('CAST(score AS float)')
          end
        end

end