#
# Module structure and user activity in a tabular form
#
# :nocov
class ModuleDebugDecorator < DelegateClass(ModuleProgress)
  # @return [String]
  def markdown_table
    body = []
    body << '|'
    rows.each do |row|
      row.each do |value|
        body << value
        body << '|'
      end
      body << "\n"
    end
    body << "\n"

    body.join
  end

private

  # @return [Array<String>]
  HEADERS = [
    'Position',
    'Visited',
    'Sections',
    'Progress',
    'Submodule',
    'Topic',
    'Pages',
    'Model',
    'Type',
    'Name',
  ].freeze

  # @return [Array<Array>]
  def columns
    mod.content.each.with_index(1).map do |item, pos|
      pagination = PaginationDecorator.new(item)
      [
        pos.ordinalize,
        visited?(item),
        pagination.section_numbers,
        pagination.percentage,
        item.submodule,
        item.topic,
        pagination.page_numbers,
        item.content_type.id,
        item.page_type,
        item.name,
      ]
    end
  end

  # @return [Array<Array>]
  def rows
    [HEADERS, *columns]
  end
end
# :nocov
