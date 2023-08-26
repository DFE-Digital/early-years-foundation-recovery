# User's course progress and module state used on the 'My modules' page
#
class CourseProgress
  extend Dry::Initializer

  option :user, required: true

  # @return [Array<Training::Module>] 'Modules in progress' section
  def current_modules
    by_state(:active)
  end

  # @return [Array<Training::Module>] 'Available modules' section
  def available_modules
    by_state(:upcoming).select { |mod| available?(mod) && !mod.draft? }
  end

  # @return [Array<Training::Module>] 'Future modules in this course' section
  def upcoming_modules
    by_state(:upcoming).select { |mod| !available?(mod) || mod.draft? }
  end

  # @return [Array<Array>] 'Completed modules' section
  def completed_modules
    by_state(:completed).map do |mod|
      [mod, module_progress(mod).completed_at]
    end
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
        published at: #{mod.published_at}
        position: #{mod.position}
        name: #{mod.name}
        draft: #{mod.draft?}
        started: #{started?(mod)}
        completed: #{completed?(mod)}
        available: #{available?(mod)}
        last: #{mod.thankyou_page&.name unless mod.draft?}
        certificate: #{mod.certificate_page&.name unless mod.draft?}
        milestone: #{module_progress(mod).milestone}
      SUMMARY
    end
  end

private

  # @param mod [Training::Module]
  # @return [Boolean] module content has been viewed
  def started?(mod)
    return false if mod.draft?

    module_progress(mod).started?
  end

  # @param mod [Training::Module]
  # @return [Boolean]
  def completed?(mod)
    return false if mod.draft?

    module_progress(mod).completed?
  end

  # @param mod [Training::Module]
  # @return [Boolean]
  def active?(mod)
    started?(mod) && !completed?(mod)
  end

  # @param mod [Training::Module]
  # @return [Boolean]
  def upcoming?(mod)
    !started?(mod) && !completed?(mod)
  end

  # @param mod [Training::Module]
  # @return [Boolean] true unless a mandatory prerequisite module must be finished
  def available?(mod)
    mod.depends_on.present? ? completed?(mod.depends_on) : true
  end

  # @param state [Symbol, String] :active, :upcoming or :completed
  # @return [Array<Training::Module>] training modules by state
  def by_state(state)
    case state.to_sym
    when :active    then training_modules.select { |mod| active?(mod) }
    when :upcoming  then training_modules.select { |mod| upcoming?(mod) }
    when :completed then training_modules.select { |mod| completed?(mod) }
    else
      raise 'CourseProgress#by_state can query either :active, :upcoming or :completed modules'
    end
  end

  # @return [Array<Training::Module>] training modules with finalised content
  def published_modules
    training_modules.reject(&:draft?)
  end

  # @return [Array<Training::Module>]
  def training_modules
    @training_modules ||= Training::Module.ordered
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
