class NewModuleMailJob < MailJob
  # @param release_id [Integer]
  # @return [void]
  def run(release_id)
    super do
      return if ModuleRelease.count.zero?

      find_module = new_module
      return if find_module.nil?

      notify_users(new_module)
      log_mail_job
      create_published_record(new_module, Release.find(release_id))
    end
  end

  # @return [Array<User>]
  def recipients
    User.completed_available_modules
  end

private

  # @param mod [Training::Module]
  # @return [void]
  def notify_users(mod)
    recipients.each { |recipient| recipient.send_new_module_notification(mod) }
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

  # @return [Training::Module, nil]
  def new_module
    latest_published = Training::Module.live.last
    if latest_published.position == ModuleRelease.ordered.last.module_position
      nil
    else
      latest_published
    end
  end
end
