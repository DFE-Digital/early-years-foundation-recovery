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
  def self.start_training
    by_job_class('StartTrainingMailJob')
  end
end
