# New taks should be added here when we add a new table which needs to have data analysed.
# Upload csv files to Google storage from DB
namespace :db do
  namespace :analytics do
    desc 'Users table'
    task users: :environment do
      # due to the nature of the dynamic json objects stored in the column  we need to get the largest column data and run through
      # AnalyticsBuild::build_json_sql function to create a sql which can be used to populate csv files.
      # we use COALESCE function to add null value as currently we find on occassions google data studio struggles with empty values.

      # REMOVE THESE: once we fix the data dashboard to match dynamic keys we can remove these from sql
      # COALESCE(module_time_to_completion->>'child-development-and-the-eyfs', 'null') AS module_1_time,
      # COALESCE(module_time_to_completion->>'brain-development-and-how-children-learn', 'null') AS module_2_time,
      # COALESCE(module_time_to_completion->>'personal-social-and-emotional-development', 'null') AS module_3_time,
      # COALESCE(module_time_to_completion->>'module-4', 'null') AS module_4_time,

      sql = 'SELECT id, module_time_to_completion as json_column, (SELECT COUNT(*) FROM jsonb_object_keys(module_time_to_completion)) nbr_keys FROM public.users order by nbr_keys desc limit 1'
      user_json = ActiveRecord::Base.connection.execute(sql)
      users_all = User.select(" id,
                                TO_CHAR(created_at, 'YYYY-MM-DD') AS registered_at,
                                COALESCE(NULLIF(setting_type, 'other'), COALESCE(setting_type_other, 'null')) AS user_setting,
                                COALESCE(module_time_to_completion->>'child-development-and-the-eyfs', 'null') AS module_1_time,
                                COALESCE(module_time_to_completion->>'brain-development-and-how-children-learn', 'null') AS module_2_time,
                                COALESCE(module_time_to_completion->>'personal-social-and-emotional-development', 'null') AS module_3_time,
                                COALESCE(module_time_to_completion->>'module-4', 'null') AS module_4_time,
                                #{AnalyticsBuild.build_json_sql('module_time_to_completion', JSON.parse(user_json.first['json_column']))}
                                module_time_to_completion").all

      users = AnalyticsBuild.new(bucket_name: ENV['GCS_BUCKET_NAME'],
                                 folder_path: 'userdata',
                                 result_set: users_all, file_name: 'users')

      # comment out the following 3 lines to create csv on local machine
      users.create! if Rails.env.test?
      users.delete_files if Rails.env.production? || Rails.env.development?
      users.upload if Rails.env.production? || Rails.env.development?
      
      # uncomment this line to create csv file on local machine
      # users.create!
    end

    desc 'ahoy_events table'
    task ahoy_events: :environment do
      sql = 'SELECT id, properties as json_column, (SELECT COUNT(*) FROM jsonb_object_keys(properties)) nbr_keys FROM public.ahoy_events order by nbr_keys desc limit 1'
      event_json = ActiveRecord::Base.connection.execute(sql)
      events_results = Ahoy::Event.select(" id, visit_id,
                                            user_id,
                                            COALESCE(name, 'null') as name,
                                            TO_CHAR(time, 'YYYY-MM-DD HH:MM:SS') as event_time,
                                            #{AnalyticsBuild.build_json_sql('properties', JSON.parse(event_json.first['json_column']))}
                                            properties").where.not(name: 'module_content_page')
      events = AnalyticsBuild.new(bucket_name: ENV['GCS_BUCKET_NAME'],
                                  folder_path: 'eventsdata',
                                  result_set: events_results,
                                  file_name: 'ahoy_events')

      # comment out the following 3 lines to create csv on local machine
      events.create! if Rails.env.test?
      events.delete_files if Rails.env.production? || Rails.env.development?
      events.upload if Rails.env.production? || Rails.env.development?
      
      # uncomment this line to create csv file on local machine
      # events.create!
    end

    desc 'user_assessments table'
    task user_assessments: :environment do
      user_assessments = UserAssessment.all
      assessments = AnalyticsBuild.new(bucket_name: ENV['GCS_BUCKET_NAME'],
                                       folder_path: 'userassessments',
                                       result_set: user_assessments,
                                       file_name: 'user_assessments')

      # comment out the following 3 lines to create csv on local machine
      assessments.create! if Rails.env.test?
      assessments.delete_files if Rails.env.production? || Rails.env.development?
      assessments.upload if Rails.env.production? || Rails.env.development?
      
      # uncomment this line to create csv file on local machine
      # assessments.create!
    end

    desc 'user_answers table'
    task user_answers: :environment do
      user_answers = UserAnswer.all
      answers = AnalyticsBuild.new(bucket_name: ENV['GCS_BUCKET_NAME'],
                                   folder_path: 'useranswers',
                                   result_set: user_answers,
                                   file_name: 'user_answers')

      # comment out the following 3 lines to create csv on local machine
      answers.create! if Rails.env.test?
      answers.delete_files if Rails.env.production? || Rails.env.development?
      answers.upload if Rails.env.production? || Rails.env.development?
      
      # uncomment this line to create csv file on local machine
      # answers.create!
    end

    desc 'ahoy_visits table'
    task ahoy_visits: :environment do
      ahoy_visits = Ahoy::Visit.select("*, TO_CHAR(started_at, 'YYYY-MM-DD HH:MM:SS') AS formated_started_at").all
      ahoy_visit = AnalyticsBuild.new(bucket_name: ENV['GCS_BUCKET_NAME'],
                                      folder_path: 'visitsdata',
                                      result_set: ahoy_visits,
                                      file_name: 'ahoy_visits')

      # comment out the following 3 lines to create csv on local machine
      ahoy_visit.create! if Rails.env.test?
      ahoy_visit.delete_files if Rails.env.production? || Rails.env.development?
      ahoy_visit.upload if Rails.env.production? || Rails.env.development?

      # uncomment this line to create csv file on local machine
      # ahoy_visit.create!
    end
  end
end
