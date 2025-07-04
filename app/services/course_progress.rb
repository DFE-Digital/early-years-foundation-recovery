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
    by_state(:upcoming).reject(&:draft?)
  end

  # @return [Array<Training::Module>] 'Future modules in this course' section
  def upcoming_modules
    by_state(:upcoming).select(&:draft?)
  end

  # @return [Array<Array>] 'Completed modules' section
  def completed_modules
    by_state(:completed).map do |mod|
      [mod, module_progress(mod).completed_at]
    end
  end

  # @return [Boolean]
  def course_completed?
    Training::Module.live.all? { |mod| completed?(mod) }
  end

  # @return [Boolean]
  def completed_all_modules?
    completed_modules.all? && upcoming_modules.none? && available_modules.none? && course_completed?
  end

  # @return [Array<String>]
  def debug_summary
    Training::Module.ordered.map { |mod|
      <<~SUMMARY
        ---
        title: #{mod.title}
        published at: #{mod.published_at || 'Management Key Missing'}
        position: #{mod.position}
        name: #{mod.name}
        draft: #{mod.draft?}
        started: #{started?(mod)}
        completed: #{completed?(mod)}
        last: #{mod.thankyou_page&.name || 'N/A'}
        certificate: #{mod.certificate_page&.name || 'N/A'}
        milestone: #{module_progress(mod).milestone || 'N/A'}
      SUMMARY
    }.join
  end

  # @param mod [Training::Module]
  # @return [Boolean]
  def completed?(mod)
    return false if mod.draft?

    module_progress(mod).completed?
  end

  # @param mod [Training::Module]
  # @return [Boolean] module content has been viewed
  def started?(mod)
    return false if mod.draft?

    module_progress(mod).started?
  end

private

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

  # @param state [Symbol, String] :active, :upcoming or :completed
  # @return [Array<Training::Module>] training modules by state
  def by_state(state)
    case state.to_sym
    when :active    then Training::Module.ordered.select { |mod| active?(mod) }
    when :upcoming  then Training::Module.ordered.select { |mod| upcoming?(mod) }
    when :completed then Training::Module.ordered.select { |mod| completed?(mod) }
    else
      raise 'CourseProgress#by_state can query either :active, :upcoming or :completed modules'
    end
  end

  # @return [ModuleProgress]
  def module_progress(mod)
    @module_progresses ||= {}
    @module_progresses[mod.name] ||= ModuleProgress.new(user: user, mod: mod, user_module_events: user.events.where_properties(training_module_id: mod.name))
  end

  # @param module_id [String] training module name
  # @return [Event::ActiveRecord_AssociationRelation]
  def training_module_events(module_id)
    user.events.where_properties(training_module_id: module_id)
  end
end
