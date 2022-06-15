# The core ActiveYaml object that gathers YAML data from /data/modules
#
#
class ModuleItem < YamlBase
  extend YamlFolder
  set_folder 'modules'

  # @overload ActiveYaml::Base load_file
  #   gets data nested within files and uses parent keys to populate attributes
  def self.load_file
    data = raw_data.map do |training_module, items|
      items.map do |name, values|
        values.merge(name: name.to_s, training_module: training_module)
      end
    end
    data.flatten! # Using flatten! as more memory efficient.
    data
  end

  # @return [Hash] 'Type' to 'View object' mapping
  MODELS = {
    module_intro: ContentPage,
    sub_module_intro: ContentPage,
    text_page: ContentPage,
    youtube_page: YoutubePage,
    formative_assessment: Questionnaire,
  }.freeze

  # @return [Regexp] 2nd digit if present: 1-[1]-1-1
  SUBMODULE_PATTERN = %r"\A(?<prefix>\d+\W){1}(?<submodule>\d+)(?=(?<suffix>\D|$))"

  # @return [Regexp] 3rd digit if present: 1-1-[1]-1
  TOPIC_PATTERN = %r"\A(?<prefix>\d+\W){2}(?<topic>\d+)(?=(?<suffix>\D|$))"

  # @return [Regexp] 4th digit (and optional suffix) if present: 1-1-1-[1a]
  # PAGE_PATTERN = %r"\A(?<prefix>\d+\W){3}(?<page>\d+)(?=(?<suffix>\D|$))".freeze
  PAGE_PATTERN = %r"\A(?<prefix>\d+\W){3}(?<page>\d+\D+)$"

  # @return [Array<ModuleItem>] module items of a specific type
  scope :where_type, lambda { |training_module, type|
    where(training_module: training_module, type: type)
  }

  # @return [Array<ModuleItem>] module items within a given module's submodule
  scope :where_submodule, lambda { |training_module, submodule_name|
    pattern = %r"\A(\d+\W){1}#{submodule_name}(?=(\D|$))"
    where(training_module: training_module).select { |m| m.name =~ pattern }
  }

  # @return [Array<ModuleItem>]
  scope :topics, lambda { |training_module|
    where(training_module: training_module).select { |m| m.topic_name.present? }
  }

  # Start with two number then non-word character pairs (e.g. 2-4- or 13.4.)
  # Can be followed by either a non-digit or end of line
  #
  # @return [Array<ModuleItem>] module items within a given module's topic
  scope :where_submodule_topic, lambda { |training_module, submodule_name, topic_name|
    pattern = %r"\A(\d+\W){2}#{topic_name}(?=(\D|$))"
    where_submodule(training_module, submodule_name).select { |m| m.name =~ pattern }
  }

  # composition ---------------------------------

  # @return [String]
  def debug_summary
    <<~SUMMARY
      id: #{id}
      module: #{training_module}
      name: #{name}

      ---
      previous: #{previous_item&.name}
      next: #{next_item&.name}
      type: #{type}

      ---
      submodule name: #{submodule_name || 'none'}
      topic name: #{topic_name || 'none'}
      page name: #{page_name || 'none'}

      ---
      position in module: #{(position_within_training_module + 1).ordinalize}
      position in submodule: #{(position_within_submodule + 1).ordinalize}
      position in topic: #{(position_within_topic + 1).ordinalize}

      ---
      submodule items count: #{number_within_submodule}
      topic items count: #{number_within_topic}
    SUMMARY
  end

  # @return [Hash<Symbol>, nil]
  def page_number
    return unless position_within_submodule

    { current: position_within_submodule, total: number_within_submodule }
  end

  # @return [TrainingModule]
  def parent
    TrainingModule.find_by(name: training_module)
  end

  # @return [ContentPage, YoutubePage, Questionnaire]
  def model
    klass = MODELS[type.to_sym]
    if klass == Questionnaire
      Questionnaire.find_by!(name: name)
    else
      klass.new(attributes)
    end
  end

  # names ---------------------------------

  # @return [String, nil] 2nd digit if present: 1-[1]-1-1
  def submodule_name
    matches = name.match(SUBMODULE_PATTERN)
    matches[:submodule] if matches
  end

  # @return [String, nil] 3rd digit if present: 1-1-[1]-1
  def topic_name
    matches = name.match(TOPIC_PATTERN)
    matches[:topic] if matches
  end

  # @return [String, nil] 4th digit (and optional suffix) if present: 1-1-1-[1a]
  def page_name
    matches = name.match(PAGE_PATTERN)
    matches[:page] if matches
  end

  # predicates ---------------------------------
  # TODO: Use types to check rather than names

  # @return [Boolean]
  delegate :valid?, to: :model

  # # @return [Boolean]
  # def topic?
  #   topic_name.present?
  # end

  # # @return [Boolean]
  # def submodule?
  #   # type.eql?('sub_module_intro')
  #   submodule_name.present?
  # end

  # position ---------------------------------

  # Module intro will be position 0
  # @return [Integer, nil] current item position (zero index)
  def position_within_training_module
    parent.module_items.index(self)
  end

  # Submodule intro will be position 0
  # @return [Integer, nil] current item position (zero index)
  def position_within_submodule
    current_submodule.index(self)
  end

  # Topic intro will be position 0
  # @return [Integer, nil] current item position (zero index)
  def position_within_topic
    current_submodule_topic.index(self)
  end

  # counters ---------------------------------

  # @return [Integer] number of module items excluding the submodule intro
  def number_within_submodule
    current_submodule.count - 1
  end

  # @return [Integer] number of module items
  def number_within_topic
    current_submodule_topic.count
  end

  # sequence ---------------------------------

  # @return [ModuleItem, nil]
  def previous_item
    return if position_within_training_module.zero?

    parent.module_items[position_within_training_module - 1]
  end

  # @return [ModuleItem, nil]
  def next_item
    parent.module_items[position_within_training_module + 1]
  end

private

  # collections -------------------------

  # @return [Array<ModuleItem>] module items in the same submodule
  def current_submodule
    self.class.where_submodule(training_module, submodule_name)
  end

  # @return [Array<ModuleItem>] module items in the same submodule and topic
  def current_submodule_topic
    self.class.where_submodule_topic(training_module, submodule_name, topic_name)
  end
end
