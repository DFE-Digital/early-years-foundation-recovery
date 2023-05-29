require 'reporting'

namespace :eyfs do
  namespace :report do
    include Reporting

    desc 'print stats to console [YAML]'
    task stats: :environment do
      # puts users.to_yaml
      # puts modules.to_yaml
      puts "high fail questions \n"
      puts Data::SummativeQuiz.high_fail_questions
      puts "average pass scores \n"
      puts Data::SummativeQuiz.average_pass_scores
      puts "setting pass percentage \n"
      puts Data::SummativeQuiz.setting_pass_percentage.to_yaml
      puts "role pass percentage \n"
      puts Data::SummativeQuiz.role_pass_percentage.to_yaml
      puts "resit attempts per user \n"
      puts Data::SummativeQuiz.resit_attempts_per_user.to_yaml
      puts "none passing users \n"
      puts Data::SummativeQuiz.total_users_not_passing_per_module
    end

    desc 'export stats to file [CSV]'
    task export: :environment do
      export_users
      export_modules
    end
  end
end
