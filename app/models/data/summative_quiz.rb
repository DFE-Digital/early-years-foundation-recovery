module Data
  class SummativeQuiz
    include ToCsv
    class << self

      def average_pass_scores_csv
        headers = ['Module', 'Average Pass Score']
        data = average_pass_scores.map { |module_name, average_score| [module_name, average_score] }
  
        generate_csv(headers, data)
      end
  
      def high_fail_questions_csv
        headers = ['Module', 'Question', 'Failure Rate Percentage']
        data = high_fail_questions.map { |(module_name, question_name), fail_rate| [module_name, question_name, fail_rate] }
        generate_csv(headers, data)
      end
  
      def setting_pass_percentage_csv
        headers = ['Setting', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
        data = setting_pass_percentage.map do |setting_type, percentages|
          [setting_type, percentages[:pass], percentages[:pass_count], percentages[:fail], percentages[:fail_count]]
        end
        generate_csv(headers, data)
      end
  
      def role_pass_percentage_csv
        headers = ['Role', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
        data = role_pass_percentage.map do |role, percentages|
          [role, percentages[:pass], percentages[:pass_count], percentages[:fail], percentages[:fail_count]]
        end
        generate_csv(headers, data)
      end
  
      def total_users_not_passing_per_module_csv
        headers = ['Module', 'Total Users Not Passing']
        data = total_users_not_passing_per_module.map { |module_name, total_users| [module_name, total_users] }
        generate_csv(headers, data)

      end
  
      def resit_attempts_per_user_csv
        user_roles = User.pluck(:id, :role_type).to_h
        headers = ['Module', 'User ID', 'Role', 'Resit Attempts']
        data = resit_attempts_per_user.map do |module_name, user_attempts|
          user_attempts.map do |user_id, attempts|
            role_type = user_roles[user_id]
            [module_name, user_id, role_type, attempts]
          end
        end
        generate_csv(headers, data)
      end

    private

      def generate_csv(headers, data)
        CSV.generate do |csv|
          csv << headers

          data.each do |row|
            csv << row
          end
        end
      end

      def high_fail_questions
        question_attempts = UserAnswer.summative.group(:module, :name).count
        question_failures = UserAnswer.summative.where(correct: false).group(:module, :name).count
        total_attempts = question_attempts.values.sum

        average_fail_rate = percentage(question_failures.values.sum, total_attempts)

        high_fail_questions = {}

        question_failures.each do |(module_name, question_name), fail_count|
          total_count = question_attempts[[module_name, question_name]]
          fail_rate = percentage(fail_count, total_count)

          if fail_rate > average_fail_rate
            high_fail_questions[[module_name, question_name]] = format_percentage(fail_rate)
          end
        end
        { average: format_percentage(average_fail_rate) }.merge(high_fail_questions)
      end

      def setting_pass_percentage
        attribute_pass_percentage(:setting_type)
      end

      def role_pass_percentage
        attribute_pass_percentage(:role_type)
      end

      def attribute_pass_percentage(attribute)
        grouped_assessments = user_summative_assessments.group(attribute).count

        grouped_assessments.transform_values do |count|
          pass_count = user_passed_assessments
          .where(attribute => grouped_assessments.key(count)).count

          pass_percentage = percentage(pass_count, count)
          fail_percentage = 100 - pass_percentage

          { pass: format_percentage(pass_percentage), pass_count: pass_count, fail: format_percentage(fail_percentage), fail_count: count - pass_count }
        end
      end

      def resit_attempts_per_user
        UserAssessment.summative
          .group(:module, :user_id)
          .count
          .each_with_object({}) do |((module_name, user_id), count), resit_attempts_per_module|
            if count > 1
              resit_attempts_per_module[module_name] ||= {}
              resit_attempts_per_module[module_name][user_id] = count - 1
            end
          end
      end

      def total_users_not_passing_per_module
        UserAssessment.summative
          .group(:module, :user_id)
          .count
          .reject { |(module_name, user_id), _| UserAssessment.summative.where(module: module_name, user_id: user_id).passes.exists? }
          .group_by { |(module_name, _), _| module_name }
          .transform_values(&:size)
      end

      def average_pass_scores
        UserAssessment.summative.passes.group(:module).average('CAST(score AS float)')
      end

      def percentage(numerator, denominator)
        percentage_value = ((numerator.to_f / denominator) * 100).round(2)
      end

      def format_percentage(percentage)
        format('%.2f', percentage)
      end

      def user_summative_assessments
        User.with_assessments.merge(UserAssessment.summative)
      end

      def user_passed_assessments
        User.with_assessments.merge(UserAssessment.summative.passes)
      end

    end
  end
end
