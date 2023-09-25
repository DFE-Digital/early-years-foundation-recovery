Que::Scheduler.configure do |config|
  config.schedule = {
    DashboardJob: { cron: Rails.application.config.dashboard_update_interval },
    CompleteRegistrationMailJob: { cron: Rails.application.config.mail_job_interval },
    StartTrainingMailJob: { cron: Rails.application.config.mail_job_interval },
    ContinueTrainingMailJob: { cron: Rails.application.config.mail_job_interval },
  }
end

# Que.logger = QUE_LOGGER

# https://github.com/que-rb/que/tree/master/docs#error-notifications
# Que.error_notifier = proc do |error, job|
# Do whatever you want with the error object or job row here. Note that the
# job passed is not the actual job object, but the hash representing the job
# row in the database, which looks like:

# {
#   :priority => 100,
#   :run_at => "2017-09-15T20:18:52.018101Z",
#   :id => 172340879,
#   :job_class => "TestJob",
#   :error_count => 0,
#   :last_error_message => nil,
#   :queue => "default",
#   :last_error_backtrace => nil,
#   :finished_at => nil,
#   :expired_at => nil,
#   :args => [],
#   :data => {}
# }

# This is done because the job may not have been able to be deserialized
# properly, if the name of the job class was changed or the job class isn't
# loaded for some reason. The job argument may also be nil, if there was a
# connection failure or something similar.
# end
