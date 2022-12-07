class ModuleProgressBarDecorator < DelegateClass(ModuleProgress)
  MILESTONES = %w[
    interruption_page
    sub_module_intro
    summary_intro
  ].freeze

  # def furthest_submodule?(item)
  #
  # end

  # @return [Hash]
  # @return [<Hash, Integer>]
  def progress_bar_info
    milestones.each_with_index.map do |item, index|
      position = "Step #{index + 1}: "
      heading = milestones.first.eql?(item) ? 'Module introduction' : item.model.heading
      first = milestones.first.eql?(item)
      style = "line line--#{icon(item)[2]}" unless milestones.first.eql?(item)
      bold = section_name(furthest_page).eql?(section_name(item))
      content_helper_values = icon(item)

      {
        heading: heading,
        class: style,
        first: first,
        bold: bold,
        position: position,
        content_helper_values: content_helper_values,
      }
    end
  end

  # public for debugging
  # @return [Array<ModuleItem>]
  def milestones
    MILESTONES.flat_map { |type| mod.module_items_by_type(type) }
  end

private

  # @return [String]
  def section_name(module_item)
    if module_item.nil?
      nil
    elsif %w[interruption_page icons_page module_intro].include?(module_item)
      'introduction'
    elsif %w[assessment_intro
             summative_questionnaire
             assessment_results
             confidence_intro
             confidence_questionnaire
             thankyou
             certificate].include?(module_item)
      'summary'
    else
      module_item.submodule_name
    end
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
      ['circle', :solid, :green, 'started']
    else
      ['circle', :regular, :grey, 'not started']
    end
  end

  # @return [Boolean]
  def milestone_completed?(item)
    if item.interruption_page?
      visited?(item.parent.intro_page)
    elsif item.summary_intro?
      visited?(item.parent.certificate_page)
    elsif item.submodule_intro?
      all?(item.current_submodule_items)
    end
  end

  # @return [Boolean]
  def milestone_started?(item)
    if item.submodule_intro? || item.summary_intro?
      visited?(item.next_item)
    else
      visited?(item)
    end
  end
end
