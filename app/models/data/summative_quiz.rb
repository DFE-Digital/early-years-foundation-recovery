module Data
    class SummativeQuiz
      include ToCsv
  
      def self.to_csv
        new.generate_csv
      end
            # @return [String]
            def generate_csv
            end

            def self.average_pass_scores_csv

              CSV.generate(headers: true) do |csv|
                csv << ['Module', 'Average Pass Score']
            
                average_pass_scores.each do |module_name, average_score|
                  csv << [module_name, average_score]
                end
              end
            end

            def self.high_fail_questions_csv
            
              CSV.generate do |csv|
                csv << ['Question', 'Failure Rate (%)']
            
                high_fail_questions.each do |question_id, fail_rate|
                  csv << [question_id, fail_rate]
                end
              end
            end

            def self.setting_pass_percentage_csv
              pass_fail_percentages = setting_pass_percentage
            
              CSV.generate do |csv|
                csv << ['Setting Type', 'Pass Percentage', 'Fail Percentage']
                pass_fail_percentages.each do |setting_type, percentages|
                  csv << [setting_type, percentages[:pass], percentages[:fail]]
                end
              end
            end
            
            def self.role_pass_percentage_csv
              pass_fail_percentages = role_pass_percentage
            
              CSV.generate do |csv|
                csv << ['Role Type', 'Pass Percentage', 'Fail Percentage']
                pass_fail_percentages.each do |role_type, percentages|
                  csv << [role_type, percentages[:pass], percentages[:fail]]
                end
              end
            end

          def self.average_pass_scores
            averages = summative_passes.group(:module).average('CAST(score AS float)')
          end

          def self.high_fail_questions
            question_attempts = UserAnswer.summative.group(:name).count
            question_failures = UserAnswer.summative.where(correct: false).group(:name).count
          
            total_questions = question_attempts.keys.size.to_f
          
            high_fail_questions = {}
          
            average_fail_rate = (question_failures.values.sum / total_questions) * 100
          
            question_failures.each do |question_id, fail_count|
              total_count = question_attempts[question_id].to_f
              fail_rate = (fail_count.to_f / total_count) * 100
          
              if fail_rate > average_fail_rate
                high_fail_questions[question_id] = fail_rate.round(2)
              end
            end
          
            {average: average_fail_rate.round(2)}.merge(high_fail_questions)
          end

          def self.setting_pass_percentage
            attribute_pass_percentage(:setting_type)
          end

          def self.role_pass_percentage
            attribute_pass_percentage(:role_type)
          end

          def self.attribute_pass_percentage(attribute)
            user_assessments = User.joins(:user_assessments)
            .merge(UserAssessment.summative)
            .group(attribute)
            .count
        
          pass_fail_percentages = user_assessments.transform_values do |count|
            pass_count = User.joins(:user_assessments)
              .merge(UserAssessment.summative.passes)
              .where(attribute => user_assessments.key(count))
              .count
        
            pass_percentage = (pass_count.to_f / count) * 100
            fail_percentage = 100 - pass_percentage
        
            { pass: pass_percentage, fail: fail_percentage }
          end
        
          pass_fail_percentages
        end


          def self.resit_attempts_per_user
          user_assessments = UserAssessment.summative.group(:user_id).count
          resits = user_assessments.select { |user, count| count > 1 }
          resit_attempts = resits.transform_values { |count| count - 1 }
          end

          def self.none_passing_users    
            summative_assessments = UserAssessment.summative.group(:user_id).count     
            never_passed = summative_assessments.select { |user, count| UserAssessment.summative.passes.where(user_id: user).count == 0 }.keys
          end
          

    private

    def self.summative_passes
      UserAssessment.summative.passes
    end

    def self.summative_assessments
      UserAssessment.summative
    end
  
    def self.summative_fails
      UserAssessment.summative.fails
    end

    end
  end
  