# :nocov:
#
# Module structure and user activity in a tabular form
#
class ModuleDebugDecorator < DelegateClass(ModuleProgress)
  # @return [Array<Array>]
  def rows
    [HEADERS, *columns]
  end

private

  # @return [Array<String>]
  HEADERS = %w[
    Position
    Visited
    Sections
    Progress
    Submodule
    Topic
    Pages
    Model
    Type
    Name
  ].freeze

  # @return [Array<Array>]
  def columns
    mod.content.each.with_index(1).map do |item, pos|
      pagination = paginate(item)
      [
        pos.ordinalize,
        visited?(item).to_s,
        pagination.section_numbers,
        pagination.percentage,
        item.submodule.to_s,
        item.topic.to_s,
        pagination.page_numbers,
        item.content_type.id,
        item.page_type,
        link_to(item),
      ]
    end
  end

  # @return [String]
  # @param item [Training::Page, Training::Question, Training::Video]
  def link_to(item)
    path = Rails.application.routes.url_helpers.training_module_page_path(mod.name, item.name)
    ApplicationController.helpers.link_to(item.name, path)
  end

  # @return [PaginationDecorator]
  # @param item [Training::Page, Training::Question, Training::Video]
  def paginate(item)
    PaginationDecorator.new(item)
  end
end
# :nocov:
