# New taks should be added here when we add a new table which needs to have data analysed.
# Upload csv files to Google storage from DB
namespace :db do
  namespace :analytics do
    desc 'Users table'
    task users: :environment do
      users_all = User.select(" id, TO_CHAR(created_at, 'YYYY-MM-DD') AS registered_at, COALESCE(NULLIF(setting_type, 'other'), setting_type_other) AS setting, postcode, module_time_to_completion").all
      users = AnalyticsBuild.new(bucket_name: 'dfetest2', folder_path: 'dfetest1/userdata', result_set: users_all, file_name: 'users', json_property_name: 'module_time_to_completion')
      users.delete_files
      users.upload
    end

    desc 'ahoy_events table'
    task ahoy_events: :environment do
      events_results = Ahoy::Event.select(' id AS events_id, visit_id, user_id, name, time, properties').all
      events = AnalyticsBuild.new(bucket_name: 'dfetest2', folder_path: 'dfetest1/eventsdata', result_set: events_results, file_name: 'ahoy_events', json_property_name: 'properties')
      events.delete_files
      events.upload
    end

    desc 'user_assessments table'
    task user_assessments: :environment do
      user_assessments = UserAssessment.all
      assessments = AnalyticsBuild.new(bucket_name: 'dfetest2', folder_path: 'dfetest1/userassessments', result_set: user_assessments, file_name: 'user_assessments')
      assessments.delete_files
      assessments.upload
    end

    desc 'user_answers table'
    task user_answers: :environment do
      user_answers = UserAnswer.all
      answers = AnalyticsBuild.new(bucket_name: 'dfetest2', folder_path: 'dfetest1/useranswers', result_set: user_answers, file_name: 'user_answers')
      answers.delete_files
      answers.upload
    end

    desc 'ahoy_visits table'
    task ahoy_visits: :environment do
      ahoy_visits = Ahoy::Visit.all
      ahoy_visit = AnalyticsBuild.new(bucket_name: 'dfetest2', folder_path: 'dfetest1/visitsdata', result_set: ahoy_visits, file_name: 'ahoy_visits')
      ahoy_visit.delete_files
      ahoy_visit.upload
    end
  end
end
