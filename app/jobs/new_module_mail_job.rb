class NewModuleMailJob < MailJob
  # @return [Array<User>]
  def self.recipients
    User.completed_available_modules
  end

  # @param release_id [Integer]
  def run(release_id)
    super do
      return unless new_module_published?

      self.class.recipients.each do |recipient|
        recipient.send_new_module_notification(latest_module)
      end

      newest_release = Release.find(release_id)

      record_module_release(latest_module, newest_release)
    end
  end

private

  # @return [Training::Module]
  def latest_module
    Training::Module.live.last
  end

  # @return [Boolean]
  def new_module_published?
    return false unless ModuleRelease.exists?

    ModuleRelease.ordered.last.module_position < latest_module.position
  end

  # @param mod [Training::Module]
  # @param release [Release]
  # @return [ModuleRelease]
  def record_module_release(mod, release)
    ModuleRelease.create!(
      release_id: release.id,
      module_position: mod.position,
      name: mod.name,
      first_published_at: release.time,
    )
  end

  # really should be a task or manual action
  # WRONG - will associate earlier modules with a release that never published them and at a wrong time
  #
  # @param release_id [Integer]
  # @return [void]
  # def populate_module_releases(release_id)
  #   Training::Module.live.each do |mod|
  #     create_published_record(mod, Release.find(release_id))
  #   end
  # end
end
