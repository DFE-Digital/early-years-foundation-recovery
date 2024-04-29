# @see HookController#release
#
# Notify users of the latest published module and record the release timestamp
class NewModuleMailJob < MailJob
  # @param release_id [Integer]
  def run(release_id)
    super do
      return unless new_module_published?

      self.class.recipients.find_each do |recipient|
        recipient.send_new_module_notification(latest_module)
      end

      record_module_release latest_module, Release.find(release_id)
    end
  end

private

  # @return [Training::Module] uncached
  def latest_module
    Training::Module.order(:position).load.to_a.select(&:named?).reject(&:draft?).last
  end

  # @return [Boolean]
  def new_module_published?
    ModuleRelease.ordered.last&.module_position.to_i < latest_module.position
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
end
