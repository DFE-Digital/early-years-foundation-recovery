# Content changes since the user's last visit, powered by Ahoy::Visit
#
class ContentChanges
  extend Dry::Initializer

  option :user, required: true

  # @return [Boolean]
  def new_modules?
    return false if previous_visit.nil?

    new_modules.any?
  end

  # @param mod [Training::Module]
  # @return [Boolean]
  def new_module?(mod)
    return false if previous_visit.nil? || user.course.started?(mod) || mod.first_published_at.nil?

    previous_visit.started_at < mod.first_published_at
  end

  # @return [Array<Training::Module>]
  def new_modules
    user.course.available_modules.select { |mod| new_module?(mod) }
  end

private

  # @return [Ahoy::Visit]
  def previous_visit
    user.visits.order(started_at: :desc).first
  end
end
