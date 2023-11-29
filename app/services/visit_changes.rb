# Gets changes since the user's last visit
#
class VisitChanges
  extend Dry::Initializer

  option :user, required: true

  # @return [Array<Training::Module>] Modules released since user's last visit
  def new_modules
    user.course.available_modules.select { |mod| new_module?(mod) }
  end

  # @param mod [Training::Module]
  # @return [Boolean] module released since user's last visit
  def new_module?(mod)
    return false unless user.previous_visits?
    return false if user.course.started?(mod)

    mod_release = ModuleRelease.find_by(module_position: mod.position)
    return false unless mod_release

    last_visit.started_at < mod_release.first_published_at
  end

private

  # @return [Visit]
  def last_visit
    user.visits.order(started_at: :desc).second
  end
end
