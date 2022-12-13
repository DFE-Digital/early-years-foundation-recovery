#
# Progress nodes are started when:
#   - interruption page in intro node is viewed
#   - first content page in submodule node is viewed
#   - recap page in module summary node is viewed
#
# Headings are bold when page is within section
#
class ModuleProgressBarDecorator < DelegateClass(ModuleProgress)
  # @return [Array<Hash{Symbol => String,Boolean,Hash}>]
  def nodes
    node_items.each.with_index(1).map do |node_item, _position|
      icon = node_icon_params(node_item)
      line_style = "line line--#{icon[:colour]}" unless node_item.eql?(node_items.first)
      # total_sections = node_items.count
      # status = node_icon_params(node_item)[:status]

      {
        heading: node_heading(node_item),
        heading_style: node_heading_style(node_item),
        icon: icon,
        line_style: line_style,
        # commented out as unused for now but may be added back in later
        # position_text: "Section #{position} of #{total_sections}: ",
        # status_text: "is #{status}",
      }
    end
  end

  # @return [String]
  def debug_summary
    # nodes.map { |node|
    #   <<~NODE

    #     ---
    #     #{node[:position]}
    #     heading: #{node[:heading]}
    #     heading_style: #{node[:heading_style]}
    #     line_style: #{node[:line_style]}
    #     icon: #{node[:icon].values}
    #   NODE
    # }.join

    node_items.map { |node_item|
      <<~NODE
        #{node_item.name}: #{node_item.type}
      NODE
    }.join
  end

  # @return [String] sentence describing furthest section visited on progress bar for screen readers
  def furthest_section
    node_items.each.with_index(1) do |item, position|
      next unless furthest_page

      if node_name(furthest_page) == node_name(item)
        title = node_heading(item)
        total_sections = node_items.count
        return "You have reached section #{position} of #{total_sections}: #{title}"
      end
    end
  end

private

  # @return [Array<String>] ModuleItem types that define node divisions
  NODE_TYPES = %w[
    interruption_page
    sub_module_intro
    summary_intro
  ].freeze

  # @return [Array<String>] ModuleItem types that form the contents of the first node
  FIRST_NODE_TYPES = %w[
    interruption_page
    icons_page
    module_intro
  ].freeze

  # @return [Array<ModuleItem>]
  def node_items
    NODE_TYPES.flat_map { |type| mod.module_items_by_type(type) }
  end

  # @return [String]
  def node_heading(node_item)
    node_items.first.eql?(node_item) ? 'Module introduction' : node_item.model.heading
  end

  # @return [nil, String] style the furthest node's heading
  def node_heading_style(node_item)
    return unless furthest_page

    'govuk-!-font-weight-bold' if node_name(furthest_page) == node_name(node_item)
  end

  # @return [String] 'start', '1', '2', etc.
  def node_name(node_item)
    FIRST_NODE_TYPES.include?(node_item.type) ? 'start' : node_item.submodule_name
  end

  # @return [String] Percentage complete
  def value
    "#{(super * 100).to_i}%"
  end

  # @see ContentHelper#progress_node
  #
  # @param node_item [ModuleItem]
  # @return [Hash{Symbol => String,Symbol}]
  def node_icon_params(node_item)
    if node_completed?(node_item)
      {
        icon_type: 'circle-check',
        style: :solid,
        colour: :green,
        status: 'completed',
      }
    elsif node_started?(node_item)
      {
        icon_type: 'circle',
        style: :solid,
        colour: :green,
        status: 'started',
      }
    else
      {
        icon_type: 'circle',
        style: :regular,
        colour: :grey,
        status: 'not started',
      }
    end
  end

  # @return [Boolean]
  def node_completed?(node_item)
    if node_item.interruption_page?
      visited? node_item.parent.intro_page
    elsif node_item.summary_intro?
      visited? node_item.parent.certificate_page
    elsif node_item.submodule_intro?
      all? node_item.current_submodule_items
    end
  end

  # @return [Boolean]
  def node_started?(node_item)
    if node_item.submodule_intro? || node_item.summary_intro?
      visited? node_item.next_item
    else
      visited? node_item
    end
  end
end
