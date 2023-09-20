# :nocov:
class FillPageViewsJob < ApplicationJob
  self.queue = 'default'
  self.priority = 1
  # self.run_at = proc { 1.minute.from_now }
  self.maximum_retry_count = 3

  def run(*)
    require 'fill_page_views'
    Training::Module.cache.clear
    log "#{self.class.name}: Running"
    FillPageViews.new.call
  end
end
# :nocov:
