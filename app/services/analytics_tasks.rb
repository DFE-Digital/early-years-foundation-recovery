class AnalyticsTasks
  Rails.application.load_tasks
  # Created this file as arask scheduler cannot run a task and cannot invoke reenable for the rake task after it is run

  def self.users
    Rake::Task['db:analytics:users'].invoke
    Rake::Task['db:analytics:users'].reenable
  end

  def self.ahoy_events
    Rake::Task['db:analytics:ahoy_events'].invoke
    Rake::Task['db:analytics:ahoy_events'].reenable
  end

  def self.user_assessments
    Rake::Task['db:analytics:user_assessments'].invoke
    Rake::Task['db:analytics:user_assessments'].reenable
  end

  def self.user_answers
    Rake::Task['db:analytics:user_answers'].invoke
    Rake::Task['db:analytics:user_answers'].reenable
  end

  def self.ahoy_visits
    Rake::Task['db:analytics:ahoy_visits'].invoke
    Rake::Task['db:analytics:ahoy_visits'].reenable
  end
end
