module SchedulerHelper
  def job_queued?
    Que.job_stats.any? { |job| job[:job_class] == self.class.name && job[:count] > 1 }
  end
end
