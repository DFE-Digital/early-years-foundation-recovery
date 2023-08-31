class NewModuleMailJob < MailJob
  # @param release_id [Integer]
  # @return [void]
  def run(release_id)
    super do
      return unless ModuleRelease.exists?

      return unless new_module_published?

      notify_users
      log_mail_job
      create_published_record(latest_module, Release.find(release_id))
    end
  end

  # @return [Array<User>]
  def recipients
    User.completed_available_modules
  end

private

  # @return [Training::Module]
  def latest_module
    Training::Module.live.last
  end

  # @return [Boolean]
  def new_module_published?
    ModuleRelease.ordered.last.module_position != Training::Module.live.last.position
  end

  # @return [void]
  def notify_users
    recipients.each { |recipient| recipient.send_new_module_notification(latest_module) }
  end

  # @param mod [Training::Module]
  # @param release [Release]
  # @return [ModuleRelease]
  def create_published_record(mod, release)
    ModuleRelease.create!(release_id: release.id, module_position: mod.position, name: mod.name, first_published_at: release.time)
  end

  # @param release_id [Integer]
  # @return [void]
  def populate_module_releases(release_id)
    Training::Module.live.each do |mod|
      create_published_record(mod, Release.find(release_id))
    end
  end
end
