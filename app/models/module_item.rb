# The core ActiveYaml object that gathers YAML data from /data/modules
class ModuleItem < YamlBase
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
  scope :where_topic, lambda { |training_module, topic|
    pattern = /\A\d+\W#{topic}(?=(\D|$))/ # Start with number, then non-word (e.g. - or .). Can be followed by either a non-digit or end of line
    where(training_module: training_module).select { |m| m.name =~ pattern }
  }

  # rubocop:disable Lint/MixedRegexpCaptureTypes
  def topic
    pattern = /\A\d+\W(?<topic>\d+)(?=(\D|$))/
    matches = name.match(pattern)
    matches[:topic] if matches
  end
  # rubocop:enable Lint/MixedRegexpCaptureTypes

  def position_within_topic
    self.class.where_topic(training_module, topic).index(self)
  end

  def position_within_training_module
    self.class.where(training_module: training_module).to_a.index(self)
  end

  def model
    klass = MODELS[type.to_sym]
    if klass == Questionnaire
      Questionnaire.find_by(name: name)
    else
      klass.new(attributes)
    end
  end
  delegate :valid?, to: :model

  def next_item
    module_items_in_this_training_module[place_in_flow + 1]
  end

  def previous_item
    return if place_in_flow.zero?

    module_items_in_this_training_module[place_in_flow - 1]
  end

  def place_in_flow
    module_items_in_this_training_module.index(self)
  end

  def module_items_in_this_training_module
    @module_items_in_this_training_module ||= self.class.where(training_module: training_module).to_a
  end
end
