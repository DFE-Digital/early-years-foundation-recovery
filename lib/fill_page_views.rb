# Assumes gaps in page views due to skipping or revisions to content
#
# Loop over active users and modules and inject page view events for skipped pages
#
class FillPageViews
  def call
    users.find_each(batch_size: 1_000) do |user|
      unless user.registration_complete
        log "user [#{user.id}]"
        next
      end

      tracker = Ahoy::Tracker.new(user: user, controller: 'training/pages')

      training_modules.each do |mod|
        progress = ModuleProgress.new(user: user, mod: mod)

        unless progress.furthest_page
          log "user [#{user.id}] module [#{mod.position}] - not started"
          next
        end

        unless progress.skipped?
          log "user [#{user.id}] module [#{mod.position}] - not skipped"
          next
        end

        skipped = 0
        page = progress.furthest_page.name

        mod.content.each do |content|
          break if content.eql?(progress.furthest_page.next_item)

          if progress.visited?(content)
            next
          else
            tracker.track('module_content_page', {
              uid: content.id,
              mod_uid: mod.id,
              skipped: true,
              id: content.name,
              action: 'show',
              controller: 'training/pages',
              training_module_id: mod.name,
            })

            skipped += 1
          end
        end

        log "user [#{user.id}] module [#{mod.position}] - [#{skipped}] skipped before page [#{page}]"
      end
    end
  end

private

  def users
    User.order(:id).all
  end

  def training_modules
    Training::Module.ordered
  end

  # @param message [String]
  # @return [String, nil]
  def log(message)
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    elsif ENV['VERBOSE'].present?
      puts message
    end
  end
end
