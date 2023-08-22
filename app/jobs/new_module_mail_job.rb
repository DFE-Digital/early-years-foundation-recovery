class NewModuleMailJob < ApplicationJob
  # @param release_id [Integer]
  # @return [void]
  def run(release_id)
    super do
      return if new_module.nil?

      notify_users(new_module)
      create_published_record(new_module, Release.find(release_id))
    end
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
    latest_published = Training::Module.ordered.reject(&:draft?).last
    if latest_published.position == ModuleRelease.ordered.last.module_position
      nil
    else
      latest_published
    end
  end
end