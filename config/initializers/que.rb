# @note
#   Que::Scheduler::Migrations.reenqueue_scheduler_if_missing
#
Que::Scheduler.configure do |config|
  config.schedule = {
    DashboardJob: { cron: Rails.application.config.dashboard_update_interval },
    CompleteRegistrationMailJob: { cron: Rails.application.config.mail_job_interval },
    StartTrainingMailJob: { cron: Rails.application.config.mail_job_interval },
    ContinueTrainingMailJob: { cron: Rails.application.config.mail_job_interval },
  }
end

# @see https://github.com/que-rb/que/tree/master/docs#error-notifications
#
Que.error_notifier = proc do |error, job|
  Sentry.with_scope do |scope|
    scope.set_tags(component: 'que-worker', job_class: job[:job_class], queue: job[:queue])
    scope.set_context('que_job', job)
    Sentry.capture_exception(error)
  end
end

Que.logger = Rails.logger
