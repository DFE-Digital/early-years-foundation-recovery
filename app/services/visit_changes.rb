# Changes since the user's last visit
#
# ContentChanges (powered by visits) might be more appropriate?
class VisitChanges
  extend Dry::Initializer

  option :user, required: true

  # @return [Boolean]
  def new_modules?
    previous_visit && new_modules.any?
  end

  # @param mod [Training::Module]
  # @return [Boolean]
  def new_module?(mod)
    return false if user.course.started?(mod)

    previous_visit && previous_visit.started_at.to_i < mod.first_published_at.to_i
  end

  # @return [Array<Training::Module>]
  def new_modules
    user.course.available_modules.select { |mod| new_module?(mod) }
  end

private

  # @return [Ahoy::Visit]
  def previous_visit
    user.visits.order(started_at: :desc).second
  end
end
