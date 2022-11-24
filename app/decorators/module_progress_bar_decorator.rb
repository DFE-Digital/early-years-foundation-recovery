class ModuleProgressBarDecorator < DelegateClass(ModuleProgress)
  MILESTONES = %w[
    module_intro
    sub_module_intro
    summary_intro
  ].freeze

  # @return [Array<ModuleItem>]
  def milestones
    MILESTONES.flat_map { |type| mod.module_items_by_type(type) }
  end

  # @return [String] Percentage complete
  def value
    "#{(super * 100).to_i}%"
  end

  # @see ContentHelper#progress_ball
  #
  # @param [ModuleItem] milestone item
  # @return [Array<String,Symbol>] milestone indicator
  def icon(item)
    if milestone_completed?(item)
      ['circle-check', :solid, :green, 'completed']
    elsif milestone_started?(item)
      ['circle', :regular, :green, 'started']
    else
      ['circle', :regular, :grey, 'not started']
    end
  end

private

  # @return [Boolean]
  def milestone_completed?(item)
    if item.module_intro?
      visited?(item)
    elsif item.summary_intro?
      visited?(item.parent.certificate_page)
    elsif item.submodule_intro?
      all?(item.current_submodule_items)
    end
  end

  # @return [Boolean]
  def milestone_started?(item)
    if item.module_intro? || item.summary_intro?
      visited?(item)
    elsif item.submodule_intro?
      visited?(item.next_item)
    end
  end
end
