# Assumes gaps in page views due to skipping or revisions to content
#
# Loop over active users and modules and inject page view events for skipped pages
#
class FillPageViews
  def call
    users.each do |user|
      unless user.registration_complete
        log "user [#{user.id}]"
        next
      end

      tracker = event_tracker(user)

      training_modules.each do |mod|
        progress = ModuleProgress.new(user: user, mod: mod)

        # next_progress = ModuleProgress.new(user: user, mod: mod.next_module)

        # if next_progress.started? && !progress.certified?
        #   log "user [#{user.id}] module [#{mod.id}] certificate skipped before [#{next_progress.mod.id}] started"
        #   track(mod, mod.certificate_page)
        # end

        unless progress.furthest_page
          log "user [#{user.id}] module [#{mod.id}] - not started"
          next
        end

        unless progress.skipped?
          log "user [#{user.id}] module [#{mod.id}] - not skipped"
          next
        end

        skipped = 0
        page = progress.furthest_page.name

        mod.module_items.each do |item|
          break if item.eql?(progress.furthest_page.next_item)

          if progress.visited?(item)
            next
          else
            track(tracker, mod, item)
            skipped += 1
          end
        end

        log "user [#{user.id}] module [#{mod.id}] - [#{skipped}] skipped before page [#{page}]"
      end
    end
  end

private

  def track(tracker, mod, item)
    tracker.track('module_content_page', {
      skipped: true,
      id: item.name,
      type: item.type,
      action: 'show',
      controller: 'content_pages',
      training_module_id: mod.name,
    })
  end

  def event_tracker(user)
    Ahoy::Tracker.new(user: user, controller: 'content_pages')
  end

  def users
    User.order(:id).all
  end

  def training_modules
    TrainingModule.published
  end

  def log(message)
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    else
      puts message
    end
  end
end
