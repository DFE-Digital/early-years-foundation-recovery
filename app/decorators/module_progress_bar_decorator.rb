# This decorator is adding functionality to meet these criteria:
#   - Progress ball is started when:
#     - interruption page in intro section is viewed
#     - first content page in submodule is viewed
#     - recap page in module summary section is viewed
#   - Headings are bold when page is within section

class ModuleProgressBarDecorator < DelegateClass(ModuleProgress)
  MILESTONES = %w[
    interruption_page
    sub_module_intro
    summary_intro
  ].freeze

  # @return [Array<Hash{Symbol => String,Boolean,Hash}>]
  def progress_bar_attributes
    milestones.each_with_index.map do |item, index|
      heading = milestones.first.eql?(item) ? 'Module introduction' : item.model.heading
      style = "line line--#{icon(item)[:colour]}" unless milestones.first.eql?(item)
      first = milestones.first.eql?(item)
      bold = section_name(furthest_page).eql?(section_name(item))
      position = "Step #{index + 1}: "
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
    else
      module_item.submodule_name
    end
  end

  # @return [String] Percentage complete
  def value
    "#{(super * 100).to_i}%"
  end

  # @see ContentHelper#progress_node
  #
  # @param [ModuleItem] milestone item
  # @return [Hash{Symbol => String,Symbol}] milestone indicator
  def icon(item)
    if milestone_completed?(item)
      icon_type = 'circle-check'
      style = :solid
      colour = :green
      status = 'completed'
    elsif milestone_started?(item)
      icon_type = 'circle'
      style = :solid
      colour = :green
      status = 'started'
    else
      icon_type = 'circle'
      style = :regular
      colour = :grey
      status = 'not started'
    end
    {
      icon_type: icon_type,
      style: style,
      colour: colour,
      status: status,
    }
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
