# The core ActiveYaml object that gathers YAML data from /data/modules
#
#
class ModuleItem < YamlBase
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

  # Start with two number then non-word character pairs (e.g. 2-4- or 13.4.)
  # Can be followed by either a non-digit or end of line
  #
  # @return [Array<ModuleItem>] module items within a given module's topic
  scope :where_topic, lambda { |training_module, topic_name|
    pattern = %r"\A(\d+\W){2}#{topic_name}(?=(\D|$))"
    where(training_module: training_module).select { |m| m.name =~ pattern }
  }

  # @return [Array<ModuleItem>] module items within a given module's submodule
  scope :where_submodule, lambda { |training_module, submodule_name|
    pattern = %r"\A(\d+\W){1}#{submodule_name}(?=(\D|$))"
    where(training_module: training_module).select { |m| m.name =~ pattern }
  }

  # @return [Array<ModuleItem>] module items of a specific type
  scope :where_type, lambda { |training_module, type|
    where(training_module: training_module, type: type)
  }

  # composition ---------------------------------

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
    name.match(SUBMODULE_PATTERN)[:submodule]
  end

  # @return [String, nil] 3rd digit if present: 1-1-[1]-1
  def topic_name
    name.match(TOPIC_PATTERN)[:topic]
  end

  # @return [String, nil] 4th digit if present: 1-1-1-[1]
  def page_name
    name.match(PAGE_PATTERN)[:page]
  end

  # predicates ---------------------------------

  # @return [Boolean]
  delegate :valid?, to: :model

  # @return [Boolean] if the page name has a third digit
  def topic?
    topic.present?
  end

  # @return [Boolean]
  def submodule?
    type.eql?('sub_module_intro')
  end

  # position ---------------------------------

  # @return [Integer, nil] current item position (zero index)
  def position_within_training_module
    parent.module_items.index(self)
  end

  # @return [Integer, nil] current item position (zero index)
  def position_within_submodule
    self.class.where_submodule(training_module, submodule_name).index(self)
    # parent.module_items_by_submodule(submodule_name).index(self)
  end

  # @return [Integer, nil] current item position (zero index)
  def position_within_topic
    self.class.where_topic(training_module, topic_name).index(self)
    # parent.module_items_by_topic(topic_name).index(self)
  end

  # counters ---------------------------------

  # @return [Integer]
  def number_within_submodule
    self.class.where_submodule(training_module, submodule_name).count
    # parent.module_items_by_submodule(submodule_name).count
  end

  # @return [Integer]
  def number_within_topic
    self.class.where_topic(training_module, topic_name).count
    # parent.module_items_by_topic(topic_name).count
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
end
