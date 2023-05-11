#
# Progress nodes are started when:
#   - interruption page in intro node is viewed
#   - first content page in submodule node is viewed
#   - recap page in module summary node is viewed
#
# Headings are bold when page is within section
#
class ContentfulModuleProgressBarDecorator < DelegateClass(ContentfulModuleProgress)
  # @return [Array<Hash{Symbol => String,Boolean,Hash}>]
  def nodes
    node_items.map do |node_item|
      icon = node_icon_params(node_item)
      line_style = "line line--#{icon[:colour]}" unless first?(node_item)

      {
        heading: node_item.heading,
        heading_style: node_heading_style(node_item),
        icon: icon,
        line_style: line_style,
      }
    end
  end

  # @return [String]
  def debug_summary
    node_items.map { |node_item|
      <<~NODE
        #{node_item.name}: #{node_item.page_type}
      NODE
    }.join
  end

  # @return [String] sentence describing furthest section visited on progress bar for screen readers
  def furthest_section
    node_items.each.with_index(1) do |node_item, position|
      next unless furthest_page

      if furthest?(node_item)
        return "You have reached section #{position} of #{node_items.count}: #{node_item.heading}"
      end
    end
  end

private

  # @return [Array<Module::Content>]
  def node_items
    %w[sub_module_intro summary_intro].flat_map { |type| mod.page_by_type(type) }
  end

  # @return [nil, String] style the furthest node's heading
  def node_heading_style(node_item)
    return unless furthest_page

    'govuk-!-font-weight-bold' if furthest?(node_item)
  end

  # @return [String] Percentage complete
  def value
    "#{(super * 100).to_i}%"
  end

  # @see ContentHelper#progress_node
  #
  # @param node_item [Module::Content]
  # @return [Hash{Symbol => String,Symbol}]
  def node_icon_params(node_item)
    if completed? || node_completed?(node_item)
      {
        icon_type: 'circle-check',
        style: :solid,
        colour: :green,
        status: 'completed',
      }
    elsif visited?(node_item)
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
    if node_item.summary_intro?
      visited? node_item.parent.certificate_page
    elsif node_item.submodule_intro?
      all? node_item.current_submodule_items
    end
  end

  # @return [Boolean]
  def first?(node_item)
    node_items.first.eql? node_item
  end

  # @return [Boolean]
  def furthest?(node_item)
    furthest_page.submodule.eql? node_item.submodule
  end
end
