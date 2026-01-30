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
    course_completed? && current_modules.none? && available_modules.none? && upcoming_modules.none?
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

  # @return [Hash<String, UserModuleProgress>] progress records indexed by module_name
  def progress_by_module_name
    @progress_by_module_name ||= user.user_module_progress.index_by(&:module_name)
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
    @module_progress_by_name ||= {}
    @module_progress_by_name[mod.name] ||= ModuleProgress.new(
      user: user,
      mod: mod,
      user_module_progress: progress_by_module_name[mod.name],
    )
  end
end
