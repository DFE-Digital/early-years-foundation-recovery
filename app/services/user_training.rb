# User's course progress and module state
#
class UserTraining
  def initialize(user:)
    @user = user
  end

  attr_reader :user

  # @return [Array<TrainingModule>] training modules that have been started
  def current_modules
    by_state(:active)
  end

  # @return [Array<TrainingModule>] published training modules with no incomplete dependency
  def available_modules
    by_state(:upcoming).select { |mod| available?(mod) && !mod.draft? }
  end

  # @return [Array<TrainingModule>] three unavailable or draft modules
  def upcoming_modules
    by_state(:upcoming).reject { |mod| available?(mod) }.take(3)
  end

  # TODO: use a dedicated event for module completion
  #
  # @return [Array<Array>] Tabular data of completed training module
  def completed_modules
    by_state(:completed).map do |mod|
      final_page = mod.module_items.last.name
      completed_at = training_module_events(mod).where_properties(id: final_page).first.time

      [mod, completed_at]
    end
  end

  # @return [String] training module 'milestone' content id
  def last_page_for(mod)
    page = training_module_events(mod).last
    page.properties['id'] if page.present?
  end

  # @return [Boolean]
  def course_completed?
    training_modules.all? { |mod| completed?(mod) }
  end

  # @return [Array<String>]
  def debug_summary
    training_modules.map do |mod|
      <<~SUMMARY
        title: #{mod.title}
        name: #{mod.name}
        draft: #{!mod.draft.nil?}
        started: #{started?(mod)}
        completed: #{completed?(mod)}
        available: #{available?(mod)}
        last: #{mod.module_items.last.name unless mod.draft?}
        furthest: #{last_page_for(mod)}
      SUMMARY
    end
  end

private

  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def training_module_events(mod)
    user.events.where_properties(training_module_id: mod.name)
  end

  # @return [Array<TrainingModule>] training modules by state
  def by_state(state)
    case state.to_sym
    when :active    then training_modules.select { |mod| active?(mod) }
    when :upcoming  then training_modules.select { |mod| upcoming?(mod) }
    when :completed then training_modules.select { |mod| completed?(mod) }
    else
      raise 'UserTraining#by_state can query either :active, :upcoming or :completed modules'
    end
  end

  # @return [Boolean]
  def active?(mod)
    started?(mod) && !completed?(mod)
  end

  # @return [Boolean]
  def upcoming?(mod)
    !started?(mod) && !completed?(mod)
  end

  # @return [Boolean] true unless a mandatory prerequisite module must be finished
  def available?(mod)
    dependent = TrainingModule.find_by(name: mod.depends_on)
    dependent ? completed?(dependent) : true
  end

  # @return [Boolean] module content has been viewed
  def started?(mod)
    return false if mod.draft?

    training_module_events(mod).where_properties(id: mod.first_content_page.name).present?
  end

  # TODO: this state is currently true if the last page was viewed
  #
  # @return [Boolean]
  def completed?(mod)
    return false if mod.draft?

    training_module_events(mod).where_properties(id: mod.module_items.last.name).present?
  end

  def training_modules
    @training_modules ||= TrainingModule.all
  end
end
