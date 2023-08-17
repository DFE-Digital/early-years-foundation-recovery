# DashboardJob.enqueue
#
class DashboardJob < ScheduledJob
  # Jobs will default to priority 100 and run immediately
  # a lower number is more important
  #
  # self.queue = 'default'
  # self.run_at = proc { 1.minute.from_now }
  # self.priority = 10

  # @param upload [Boolean] defaults to true in production or if $DASHBOARD_UPDATE exists
  def run(upload: Rails.application.dashboard?)
    log "DashboardJob: Running upload=#{upload}"

    Dashboard.new(path: build_dir).call(upload: upload, clean: true)
  end

private

  # @return [Pathname]
  def build_dir
    Rails.root.join('tmp')
  end
end
