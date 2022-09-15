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
    # intros
    module_intro: ContentPage,
    sub_module_intro: ContentPage,
    assessment_intro: ContentPage,
    confidence_intro: ContentPage,
    # static content
    interruption_page: ContentPage,
    prompt_page: ContentPage,
    # dynamic content
    text_page: ContentPage,
    # video
    youtube_page: YoutubePage,
    # questions
    confidence_questionnaire: Questionnaire,
    formative_questionnaire: Questionnaire,
    summative_questionnaire: Questionnaire,
    # test score
    assessment_results: AssessmentResultsPage,
    # pdf
    certificate: CertificatePage,
  }.freeze

  # @return [Regexp] 2nd digit if present: 1-[1]-1-1
  SUBMODULE_PATTERN = %r"\A(?<prefix>\d+\W){1}(?<submodule>\d+)(?=(?<suffix>\D|$))"

  # @return [Regexp] 3rd digit if present: 1-1-[1]-1
  TOPIC_PATTERN = %r"\A(?<prefix>\d+\W){2}(?<topic>\d+)(?=(?<suffix>\D|$))"

  # @return [Regexp] 4th digit (and optional suffix) if present: 1-1-1-[1a]
  # PAGE_PATTERN = %r"\A(?<prefix>\d+\W){3}(?<page>\d+)(?=(?<suffix>\D|$))".freeze
  PAGE_PATTERN = %r"\A(?<prefix>\d+\W){3}(?<page>\d+\D*)$"

  # @return [Array<ModuleItem>] module items of a specific type
  scope :where_type, lambda { |training_module, type|
    where(training_module: training_module, type: type)
  }

  # @return [Array<ModuleItem>] module items within a given module's submodule
  scope :where_submodule, lambda { |training_module, submodule_name|
    pattern = %r"\A(\d+\W){1}#{submodule_name}(?=(\D|$))"
    where(training_module: training_module).select { |m| m.name =~ pattern }
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
      name: #{training_module}
      path: #{name}
      type: #{type}

      ---
      previous: #{previous_item&.name}
      next: #{next_item&.name}

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

  # @return [Hash{Symbol => nil, Integer}]
  def pagination
    { current: position_within_submodule, total: number_within_submodule }
  end

  # @return [TrainingModule]
  def parent
    TrainingModule.find_by(name: training_module)
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
    matches ? matches[:page] : 0
  end

  # predicates ---------------------------------

  # @return [Boolean]
  delegate :valid?, to: :model

  # @return [Boolean]
  def topic?
    page_name.to_i.zero?
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

  def certificate?
    type.eql?('certificate')
  end

  # position ---------------------------------

  # Module intro will be position 0
  # @return [Integer, nil] current item position (zero index)
  def position_within_module
    current_module_items.index(self)
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

  # sequence ---------------------------------

  # @return [ModuleItem, nil]
  def previous_item
    return if position_within_module.zero?

    current_module_items[position_within_module - 1]
  end

  # @return [ModuleItem, nil]
  def next_item
    current_module_items[position_within_module + 1]
  end

  # collections -------------------------

  # @return [Array<ModuleItem>] module items in the same submodule and topic
  def current_submodule_topic_items
    self.class.where_submodule_topic(training_module, submodule_name, topic_name).to_a
  end

private

  # @return [Array<ModuleItem>] module items in the same module
  def current_module_items
    # parent.module_items # alternatively
    self.class.where(training_module: training_module).to_a
  end

  # @return [Array<ModuleItem>] module items in the same submodule
  def current_submodule_items
    self.class.where_submodule(training_module, submodule_name).to_a
  end
end
