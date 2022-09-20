# User's course progress and module state
#
class CourseProgress
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

  # Completed modules are modules for which every module item has been viewed
  # completed_at comes from a specific named event
  # @return [Array<Array>] Tabular data of completed training module
  def completed_modules
    by_state(:completed).map do |mod|
      [mod, module_progress(mod).completed_at]
    end
  end

  # @param module_id [String] training module name
  # @return [String] name of last page viewed in module
  def milestone(module_id)
    page = training_module_events(module_id).last
    page.properties['id'] if page.present?
  end

  # @return [Boolean]
  def course_completed?
    published_modules.all? { |mod| completed?(mod) }
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
        milestone: #{milestone(mod.name)}
      SUMMARY
    end
  end

private

  # @param mod [TrainingModule]
  # @return [Boolean] module content has been viewed
  def started?(mod)
    return false if mod.draft?

    module_progress(mod).started?
  end

  # @param mod [TrainingModule]
  # @return [Boolean]
  def completed?(mod)
    return false if mod.draft?

    module_progress(mod).completed?
  end

  # @param mod [TrainingModule]
  # @return [Boolean]
  def active?(mod)
    started?(mod) && !completed?(mod)
  end

  # @param mod [TrainingModule]
  # @return [Boolean]
  def upcoming?(mod)
    !started?(mod) && !completed?(mod)
  end

  # @param mod [TrainingModule]
  # @return [Boolean] true unless a mandatory prerequisite module must be finished
  def available?(mod)
    dependent = TrainingModule.find_by(name: mod.depends_on)
    dependent ? completed?(dependent) : true
  end

  # @param state [Symbol, String] :active, :upcoming or :completed
  # @return [Array<TrainingModule>] training modules by state
  def by_state(state)
    case state.to_sym
    when :active    then training_modules.select { |mod| active?(mod) }
    when :upcoming  then training_modules.select { |mod| upcoming?(mod) }
    when :completed then training_modules.select { |mod| completed?(mod) }
    else
      raise 'CourseProgress#by_state can query either :active, :upcoming or :completed modules'
    end
  end

  # @return [Array<TrainingModule>] training modules with finalised content
  def published_modules
    training_modules.reject(&:draft?)
  end

  # @return [Array<TrainingModule>] all training modules
  def training_modules
    @training_modules ||= TrainingModule.all
  end

  # @return [ModuleProgress]
  def module_progress(mod)
    ModuleProgress.new(user: user, mod: mod)
  end

  # @param module_id [String] training module name
  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def training_module_events(module_id)
    user.events.where_properties(training_module_id: module_id)
  end
end
