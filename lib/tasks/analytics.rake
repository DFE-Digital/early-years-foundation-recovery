# New taks should be added here when we add a new table which needs to have data analysed.
# Upload csv files to Google storage from DB
namespace :db do
  namespace :analytics do
    desc 'Users table'
    task users: :environment do
      
      # due to the nature of the dynamic json objects stored in the column  we need to get the largest column data and run through 
      # AnalyticsBuild::build_json_sql function to create a sql which can be used to populate csv files.
      # we use COALESCE function to ass null value as currently we find on occassions google data studio struggles with empty values.

      # REMOVE THESE: once we fix the data dashboard to macth dynamic keys we can remove these from sql
      # COALESCE(module_time_to_completion->>'child-development-and-the-eyfs', 'null') AS module_1_time,
      # COALESCE(module_time_to_completion->>'brain-development-and-how-children-learn', 'null') AS module_2_time,
      # COALESCE(module_time_to_completion->>'personal-social-and-emotional-development', 'null') AS module_3_time,
      # COALESCE(module_time_to_completion->>'module-4', 'null') AS module_4_time,



      user_json = User.select("module_time_to_completion as json_column").order("pg_column_size(module_time_to_completion)").last
      users_all = User.select(" id, 
                                TO_CHAR(created_at, 'YYYY-MM-DD') AS registered_at, 
                                COALESCE(NULLIF(setting_type, 'other'), COALESCE(setting_type_other, 'null')) AS setting, 
                                COALESCE(postcode, 'null'),
                                COALESCE(module_time_to_completion->>'child-development-and-the-eyfs', 'null') AS module_1_time,
                                COALESCE(module_time_to_completion->>'brain-development-and-how-children-learn', 'null') AS module_2_time,
                                COALESCE(module_time_to_completion->>'personal-social-and-emotional-development', 'null') AS module_3_time,
                                COALESCE(module_time_to_completion->>'module-4', 'null') AS module_4_time,
                                module_time_to_completion").all

      users = AnalyticsBuild.new( bucket_name: 'eyfs-data-dashboard-live', 
                                  folder_path: 'userdata', 
                                  result_set: users_all, file_name: 'users'
                                )
      users.create
      # users.delete_files
      # users.upload
    end

    desc 'ahoy_events table'
    task ahoy_events: :environment do
      # event_json = Ahoy::Event.select("id, properties as json_column").order("pg_column_size(properties)").last
      puts event_json.inspect
      events_results = Ahoy::Event.select(" id, visit_id, 
                                            user_id, 
                                            COALESCE(name, 'null'), 
                                            TO_CHAR(time, 'YYYY-MM-DD HH:MM:SS') as event_time, 
                                            properties").where(id: 22013)
      events = AnalyticsBuild.new(  bucket_name: 'eyfs-data-dashboard-live', 
                                    folder_path: 'eventsdata', 
                                    result_set: events_results, 
                                    file_name: 'ahoy_events'
                                  )
      events.create
      # events.delete_files
      # events.upload
    end

    desc 'user_assessments table'
    task user_assessments: :environment do
      user_assessments = UserAssessment.all
      assessments = AnalyticsBuild.new( bucket_name: 'eyfs-data-dashboard-live', 
                                        folder_path: 'userassessments', 
                                        result_set: user_assessments, 
                                        file_name: 'user_assessments'
                                      )
      assessments.delete_files
      assessments.upload
    end

    desc 'user_answers table'
    task user_answers: :environment do
      user_answers = UserAnswer.all
      answers = AnalyticsBuild.new( bucket_name: 'eyfs-data-dashboard-live', 
                                    folder_path: 'useranswers', 
                                    result_set: user_answers,
                                    file_name: 'user_answers'
                                  )
      answers.delete_files
      answers.upload
    end

    desc 'ahoy_visits table'
    task ahoy_visits: :environment do
      ahoy_visits = Ahoy::Visit.all
      ahoy_visit = AnalyticsBuild.new(  bucket_name: 'eyfs-data-dashboard-live', 
                                        folder_path: 'visitsdata', 
                                        result_set: ahoy_visits, 
                                        file_name: 'ahoy_visits' 
                                      )
      ahoy_visit.delete_files
      ahoy_visit.upload
    end
  end
end
