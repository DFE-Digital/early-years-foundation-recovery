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

  # Returns all the module items that belong to a particular topic within a training module
  scope :where_topic, lambda { |training_module, topic_name|
    pattern = /\A(\d+\W){2}#{topic_name}(?=(\D|$))/ # Start with two number then non-word character pairs (e.g. 2-4- or 13.4.). Can be followed by either a non-digit or end of line
    where(training_module: training_module).select { |m| m.name =~ pattern }
  }

  # Returns all the module items that belong to a particular submodule within a training module
  scope :where_submodule, lambda { |training_module, submodule_name|
    pattern = /\A(\d+\W){1}#{submodule_name}(?=(\D|$))/
    where(training_module: training_module).select { |m| m.name =~ pattern }
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

  # @see https://docs.rubocop.org/rubocop/cops_lint.html#lintmixedregexpcapturetypes
  #
  # @return [String, nil] Third digit, if present
  def topic_name
    pattern = /\A(\d+\W){2}(?<topic>\d+)(?=(\D|$))/
    matches = name.match(pattern)
    matches[:topic] if matches
  end

  # @return [String, nil] Second digit, if present
  def submodule_name
    pattern = /\A(\d+\W){1}(?<submodule>\d+)(?=(\D|$))/
    matches = name.match(pattern)
    matches[:submodule] if matches
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
    module_items_in_this_training_module.index(self)
  end

  # @return [Integer, nil] current item position (zero index)
  def position_within_submodule
    self.class.where_submodule(training_module, submodule_name).index(self)
  end

  # @return [Integer, nil] current item position (zero index)
  def position_within_topic
    self.class.where_topic(training_module, topic_name).index(self)
  end

  # sequence ---------------------------------

  # @return [ModuleItem, nil]
  def previous_item
    return if position_within_training_module.zero?

    module_items_in_this_training_module[position_within_training_module - 1]
  end

  # @return [ModuleItem, nil]
  def next_item
    module_items_in_this_training_module[position_within_training_module + 1]
  end

  # collections -------------------------

  # @return [Array<ModuleItem>]
  def module_items_in_this_training_module
    @module_items_in_this_training_module ||= self.class.where(training_module: training_module).to_a
  end

  # # @return [Array<ModuleItem>]
  # def by_type(type)
  #   self.class.where(training_module: training_module, type: type).to_a
  # end

  # # @return [Array<ModuleItem>] type: text_page
  # def text_pages
  #   @text_pages ||= by_type('text_page')
  # end

  # # @return [Array<ModuleItem>] type: youtube_page
  # def youtube_pages
  #   @youtube_pages ||= by_type('youtube_page')
  # end

  # # @return [Array<ModuleItem>] type: formative_assessment
  # def formative_assessments
  #   @formative_assessments ||= by_type('formative_assessment')
  # end

  # # @return [Array<ModuleItem>] type: sub_module_intro
  # def sub_modules
  #   @sub_modules ||= by_type('sub_module_intro')
  # end
end
