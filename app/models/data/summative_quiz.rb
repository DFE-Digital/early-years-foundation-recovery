module Data
    class SummativeQuiz
      include ToCsv

            def self.average_pass_scores_csv
              headers = ['Module', 'Average Pass Score']
              data = average_pass_scores.map { |module_name, average_score| [module_name, average_score] }
            
              generate_csv(headers, data)
            end

            def self.high_fail_questions_csv
            headers = ['Module', 'Question', 'Failure Rate (%)']
            data = high_fail_questions.map { |(module_name, question_name), fail_rate| [module_name, question_name, fail_rate] }
            generate_csv(headers, data)
            end

            def self.setting_pass_percentage_csv            
              CSV.generate do |csv|
                csv << ['Setting Type', 'Pass Percentage', 'Pass Count', 'Fail Percentage', 'Fail Count']
                setting_pass_percentage.each do |setting_type, percentages|
                  csv << [setting_type, percentages[:pass], percentages[:pass_count], percentages[:fail], percentages[:fail_count]]
                end
              end
            end

            def self.role_pass_percentage_csv
            
              CSV.generate do |csv|
              csv << ['Role', 'Pass Percentage', 'Pass Count', 'Fail Percentage', 'Fail Count']
              role_pass_percentage.each do |role, percentages|
                csv << [role, percentages[:pass], percentages[:pass_count], percentages[:fail], percentages[:fail_count]]
              end
            end
            end

            

            def self.total_users_not_passing_per_module_csv
              CSV.generate do |csv|
                csv << ['Module', 'Total Users Not Passing']
            
                total_users_not_passing_per_module.each do |module_name, total_users|
                  csv << [module_name, total_users]
                end
              end
            end
            
            def self.resit_attempts_per_user_csv
              resit_attempts = resit_attempts_per_user
              user_roles = User.pluck(:id, :role_type).to_h
            
              CSV.generate do |csv|
                csv << ['Module', 'User ID', 'Role Type', 'Resit Attempts']
            
                resit_attempts.each do |module_name, user_attempts|
                  user_attempts.each do |user_id, attempts|
                    role_type = user_roles[user_id]
                    csv << [module_name, user_id, role_type, attempts]
                  end
                end
              end
            end

            def self.generate_csv(headers, data)
              CSV.generate do |csv|
                csv << headers
            
                data.each do |row|
                  csv << row
                end
              end
            end

          def self.average_pass_scores
            averages = summative_passes.group(:module).average('CAST(score AS float)')
          end

          def self.high_fail_questions
            question_attempts = UserAnswer.summative.group(:module, :name).count
            question_failures = UserAnswer.summative.where(correct: false).group(:module, :name).count
            total_questions = question_attempts.keys.size.to_f

            average_fail_rate = percentage(question_failures.values.sum, total_questions)
          
            high_fail_questions = {}
          
            question_failures.each do |(module_name, question_name), fail_count|
              total_count = question_attempts[[module_name, question_name]].to_f
              fail_rate = percentage(fail_count.to_f, total_count)
          
              if fail_rate > average_fail_rate
                high_fail_questions[[module_name, question_name]] = fail_rate
              end
            end
            {average: average_fail_rate}.merge(high_fail_questions)
          end

          def self.setting_pass_percentage
            attribute_pass_percentage(:setting_type)
          end

          def self.role_pass_percentage
            attribute_pass_percentage(:role_type)
          end

          def self.attribute_pass_percentage(attribute)
            user_assessments = User.with_assessments
            .merge(UserAssessment.summative)
            .group(attribute)
            .count

              pass_fail_percentages = user_assessments.transform_values do |count|
              pass_count = User.with_assessments
                      .merge(UserAssessment.summative.passes)
                      .where(attribute => user_assessments.key(count))
                      .count

              pass_percentage = percentage(pass_count, count)
              fail_percentage = 100 - pass_percentage

              { pass: pass_percentage, pass_count: pass_count, fail: fail_percentage, fail_count: count - pass_count }
              end

              pass_fail_percentages
        end
        


          def self.resit_attempts_per_user
          user_assessments = UserAssessment.summative.group(:module, :user_id).count
          resit_attempts_per_module = Hash.new { |h, k| h[k] = {} }

          user_assessments.each do |(module_name, user_id), count|
            if count > 1
              resit_attempts_per_module[module_name][user_id] = count - 1
            end
          end
          resit_attempts_per_module
          end

          def self.none_passing_users    
            summative_assessments = UserAssessment.summative.group(:user_id).count     
            never_passed = summative_assessments.select { |user, count| UserAssessment.summative.passes.where(user_id: user).count == 0 }.keys
          end

          def self.total_users_not_passing_per_module
            user_assessments = UserAssessment.summative
            .group(:module, :user_id)
            .count

            user_assessments.reject do |(module_name, user_id), _|
            UserAssessment.summative
            .where(module: module_name, user_id: user_id)
            .passes
            .exists?
            end.group_by { |(module_name, _), _| module_name }
            .transform_values(&:size)
          end
          
          

    private

    def self.percentage(count, total)
      ((count.to_f / total) * 100).round(2)
    end

    def self.summative_passes
      UserAssessment.summative.passes
    end
  
    def self.summative_fails
      UserAssessment.summative.fails
    end

    end
  end
  