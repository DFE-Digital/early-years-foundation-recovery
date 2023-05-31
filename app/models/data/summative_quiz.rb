module Data
  class SummativeQuiz
    def self.average_pass_scores_csv
      headers = ['Module', 'Average Pass Score']
      data = average_pass_scores.map { |module_name, average_score| [module_name, average_score] }

      generate_csv(headers, data)
    end

    def self.high_fail_questions_csv
      headers = ['Module', 'Question', 'Failure Rate Percentage']
      data = high_fail_questions.map { |(module_name, question_name), fail_rate| [module_name, question_name, fail_rate] }
      generate_csv(headers, data)
    end

    def self.setting_pass_percentage_csv
      CSV.generate do |csv|
        csv << ['Setting', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
        setting_pass_percentage.each do |setting_type, percentages|
          csv << [setting_type, percentages[:pass], percentages[:pass_count], percentages[:fail], percentages[:fail_count]]
        end
      end
    end

    def self.role_pass_percentage_csv
      CSV.generate do |csv|
        csv << ['Role', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
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
      user_roles = User.pluck(:id, :role_type).to_h

      CSV.generate do |csv|
        csv << ['Module', 'User ID', 'Role', 'Resit Attempts']

        resit_attempts_per_user.each do |module_name, user_attempts|
          user_attempts.each do |user_id, attempts|
            role_type = user_roles[user_id]
            csv << [module_name, user_id, role_type, attempts]
          end
        end
      end
    end

    class << self
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
        question_attempts = summative_answers.group(:module, :name).count
        question_failures = summative_answers.where(correct: false).group(:module, :name).count
        total_attempts = question_attempts.values.sum

        average_fail_rate = percentage(question_failures.values.sum, total_attempts)

        high_fail_questions = {}

        question_failures.each do |(module_name, question_name), fail_count|
          total_count = question_attempts[[module_name, question_name]]
          fail_rate = percentage(fail_count, total_count)

          if fail_rate > average_fail_rate
            high_fail_questions[[module_name, question_name]] = fail_rate
          end
        end
        { average: average_fail_rate }.merge(high_fail_questions)
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

          { pass: pass_percentage, pass_count: pass_count, fail: fail_percentage, fail_count: count - pass_count }
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
        summative_passes.group(:module).average('CAST(score AS float)')
      end

      def percentage(count, total)
        ((count.to_f / total) * 100).round(2)
      end

      def summative_passes
        UserAssessment.summative.passes
      end

      def user_summative_assessments
        User.with_assessments.merge(UserAssessment.summative)
      end

      def user_passed_assessments
        User.with_assessments.merge(UserAssessment.summative.passes)
      end

      def summative_answers
        UserAnswer.summative
      end
    end
  end
end
