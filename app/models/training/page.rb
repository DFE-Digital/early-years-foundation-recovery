class Training::Page < ContentfulModel::Base
  self.content_type_id = 'page'

  belongs_to_many :modules, class_name: 'Training::Module'

  def self.where(training_module:, slug: nil)
    find_by(module_id: training_module, slug: slug)
  end

  def parent
    modules.first
  end

  def training_module
    parent.slug
  end

  def type
    component
  end

  # @return [self]
  def model
    self
  end

  def module_item
    self
  end

  def page_numbers?
    false
  end

  def notes?
    notes
  end

  def name
    slug
  end

  def previous_item
    current_index = parent.pages.rindex(self)

    return if current_index.zero?

    parent.pages[current_index - 1]
  end

  def next_item
    current_index = parent.pages.rindex(self)
    parent.pages[current_index + 1]
  end

  # collections -------------------------

  # @return [Array<Training::Page>] pages of a specific type
  def self.where_type(training_module, type)
    find_by(module_id: training_module, component: type).load
  end

  # @return [Array<Training::Page>] pages within a given module's submodule
  def self.where_submodule(training_module, submodule_name)
    pattern = %r"\A(\d+\W){1}#{submodule_name}(?=(\D|$))"
    find_by(module_id: training_module).load.select { |m| m.slug =~ pattern }
  end

  # Start with two number then non-word character pairs (e.g. 2-4- or 13.4.)
  # Can be followed by either a non-digit or end of line
  #
  # @return [Array<Training::Page>] pages within a given module's topic
  def self.where_submodule_topic(training_module, submodule_name, topic_name)
    pattern = %r"\A(\d+\W){2}#{topic_name}(?=(\D|$))"
    where_submodule(training_module, submodule_name).select { |m| m.slug =~ pattern }
  end

  # @return [Array<ModuleItem>] module items in the same submodule and topic
  def current_submodule_topic_items
    self.class.where_submodule_topic(training_module, submodule_name, topic_name).to_a
  end

  # position ---------------------------------

  # Module intro will be position 0
  # @return [Integer, nil] current item position (zero index)
  def position_within_module
    parent.pages.rindex(self)
  end

  # Submodule intro will be position 0
  # @return [Integer, nil] current item position (zero index)
  def position_within_submodule
    current_submodule_items.index(self)
  end

  # Topic intro will be position 0
  # @return [Integer, nil] current item position (zero index)
  def position_within_topic
    current_submodule_topic_items.index(self)
  end

  # counters ---------------------------------

  # @return [Integer] number of submodule items 1-[1]-1-1, (excluding intro)
  def number_within_submodule
    if module_intro?
      0
    else
      current_submodule_items.count - 1
    end
  end

  # @return [Integer] number of topic items 1-1-[1]-1
  def number_within_topic
    current_submodule_topic_items.count
  end

  # @return [String]
  def next_button_text
    if next_item.assessment_results?
      'Finish test'
    elsif next_item.summative_questionnaire? && !summative_questionnaire?
      'Start test'
    elsif next_item.certificate?
      'Finish'
    else
      'Next'
    end
  end

  # @return [Boolean]
  def assessment_results?
    type.eql?('assessment_results')
  end

  # @return [Boolean]
  def summative_questionnaire?
    type.eql?('summative_questionnaire')
  end

  # @return [Boolean]
  def formative_questionnaire?
    type.eql?('formative_questionnaire')
  end

  # @return [Boolean]
  def confidence_questionnaire?
    type.eql?('confidence_questionnaire')
  end

  # @return [Boolean]
  def module_intro?
    type.eql?('module_intro')
  end

  # @return [Boolean]
  def assessment_intro?
    type.eql?('assessment_intro')
  end

  # @return [Boolean]
  def confidence_intro?
    type.eql?('confidence_intro')
  end

  # @return [Boolean]
  def thankyou?
    type.eql?('thankyou')
  end

  # @return [Boolean]
  def certificate?
    type.eql?('certificate')
  end

  # names ---------------------------------

  # @return [String, nil] 2nd digit if present: 1-[1]-1-1
  def submodule_name
    matches = slug.match(ModuleItem::SUBMODULE_PATTERN)
    matches[:submodule] if matches
  end

  # @return [String, nil] 3rd digit if present: 1-1-[1]-1
  def topic_name
    matches = slug.match(ModuleItem::TOPIC_PATTERN)
    matches[:topic] if matches
  end

  # @return [String, nil] 4th digit (and optional suffix) if present: 1-1-1-[1a]
  def page_name
    matches = slug.match(ModuleItem::PAGE_PATTERN)
    matches ? matches[:page] : 0
  end

  # @return [String]
  def debug_summary
    <<~SUMMARY
      id: #{id}
      name: #{training_module}
      path: #{slug}
      type: #{type}
      component: #{component}
      module_item: #{module_item}

      ---
      previous: #{previous_item&.slug}
      next: #{next_item&.slug}

      ---
      submodule name: #{submodule_name || 'N/A'}
      topic name: #{topic_name || 'N/A'}
      page name: #{page_name || 'N/A'}

      ---
      position in module: #{(position_within_module + 1).ordinalize}
      position in submodule: #{position_within_submodule ? (position_within_submodule + 1).ordinalize : 'N/A'}
      position in topic: #{position_within_topic ? (position_within_topic + 1).ordinalize : 'N/A'}

      ---
      submodule items count: #{number_within_submodule}
      topic items count: #{number_within_topic}
    SUMMARY
  end

private

  # @return [Array<Training::Page>] pages in the same module
  def current_module_items
    parent.pages # alternatively
    # self.class.where(training_module: training_module).to_a
  end

  # @return [Array<Training::Page>] pages in the same submodule
  def current_submodule_items
    self.class.where_submodule(training_module, submodule_name).to_a
  end
end
