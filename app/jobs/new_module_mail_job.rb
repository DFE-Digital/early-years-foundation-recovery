class NewModuleMailJob < ApplicationJob
  # @param release_id [Integer]
  # @return [void]
  def run(_release_id)
    # super do
    Sentry.capture_message('NewModuleMailJob running', level: :info)
    log 'NewModuleMailJob running'
    User.all.each { |recipient| NotifyMailer.email_taken(recipient) }
    # TODO: uncomment before merging
    # find_module = new_module
    # return if find_module.nil?

    # notify_users(new_module)
    # create_published_record(new_module, Release.find(release_id))
    # log "NewModuleMailJob contacted #{User.count} users"
    # Sentry.capture_message("NewModuleMailJob contacted #{User.count} users", level: :info) if Rails.application.live?
    # end
    User.all.map(&:email)
  end

private

  # @param mod [Training::Module]
  # @param release [Release]
  # @return [ModuleRelease]
  def create_published_record(mod, release)
    ModuleRelease.create!(release_id: release.id, module_position: mod.position, name: mod.name, first_published_at: release.time)
  end

  # @param mod [Training::Module]
  # @return [void]
  def notify_users(mod)
    User.completed_available_modules.each { |recipient| NotifyMailer.new_module(recipient, mod) }
  end

  # @return [Training::Module, nil]
  def new_module
    # populate_module_releases if ModuleRelease.count.zero?
    latest_published = Training::Module.live.last
    if latest_published.position == ModuleRelease.ordered.last.module_position
      nil
    else
      latest_published
    end
  end
end
