require 'que/active_record/model'

# by_args
# by_job_class
# by_queue
# by_tag
#
# errored
# expired
# finished
# ready
# scheduled
#
# not_errored
# not_expired
# not_finished
# not_ready
# not_scheduled
#
class Job < Que::ActiveRecord::Model
  # @return [Job::ActiveRecord_Relation]
  def self.start_training
    by_job_class('StartTrainingMailJob')
  end

  # @return [Job::ActiveRecord_Relation]
  def self.mail
    by_job_class('ActionMailer::MailDeliveryJob')
  end

  # @return [Job::ActiveRecord_Relation]
  def self.test_bulk_mail
    mail.where('args @> ?', [{ arguments: %w[test_bulk] }].to_json)
  end

  # @return [Job::ActiveRecord_Relation]
  def self.newest_module_mail
    mail.where('args @> ?', [{ arguments: %w[new_module] }].to_json)
  end

  # @return [Integer]
  def mail_user_id
    mailer_user_gid.split('/').last.to_i
  end

  # @return [String] "gid://early-years-foundation-recovery/User/1234"
  def mailer_user_gid
    args.first['arguments'][3]['args'].first.values.first
  end
end
