# Validate whether a module's content meets minimum functional requirements
#
class ContentfulDataIntegrity
  extend Dry::Initializer

  option :module_name, Types::String.enum(*Training::Module.ordered.map(&:name))

  VALIDATIONS = {
    # position and type
    first?: 'First page is not interruption page',
    second?: 'Second page is not submodule intro',
    penultimate?: 'Penultimate page is not thank you',
    last?: 'Last page is not certificate',

    # presence and volume
    video?: 'Missing video pages',
    results?: 'Missing assessment results page',
    assessment?: 'Not enough assessment questions',

    # structure of submodule/topic
    submodules?: 'Submodules are not consecutive incrementing from 1',
    topics?: 'Topics are not consecutive incrementing from 1',
  }.freeze

  def valid?
    VALIDATIONS.all? do |method, message|
      result = send(method)
      log(message) unless result
      result
    end
  end

  # ------------------- Correct page order ---------------------

  # @param numbers [Array<Integer>]
  # @return [Boolean]
  def consecutive_integers_from_one?(numbers)
    numbers.first.eql?(1) && numbers.each_cons(2).all? { |a, b| b == a + 1 }
  end

  # @return [Boolean]
  def submodules?
    consecutive_integers_from_one? mod.content_by_submodule.keys
  end

  # @return [Boolean]
  def topics?
    mod.content_by_submodule_topic.keys.group_by(&:first).all? do |_, sub_topics|
      consecutive_integers_from_one? sub_topics.map(&:last)
    end
  end

  def mod
    @mod ||= Training::Module.by_name(module_name)
  end

private

  # @return [String]
  def log(message)
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    else
      puts message
    end
  end

  # ------------------- Required page types ---------------------

  def page_by_type_position(type:, position: nil)
    return mod.content.map(&:page_type).any?(type) unless position

    mod.content[position].page_type.eql?(type)
  rescue NoMethodError
    false
  end

  def video?
    page_by_type_position(type: 'video_page')
  end

  def results?
    page_by_type_position(type: 'assessment_results')
  end

  def first?
    page_by_type_position(type: 'interruption_page', position: 0)
  end

  def second?
    page_by_type_position(type: 'sub_module_intro', position: 1)
  end

  def penultimate?
    page_by_type_position(type: 'thankyou', position: -2)
  end

  def last?
    page_by_type_position(type: 'certificate', position: -1)
  end

  def assessment?
    return true if ContentfulRails.configuration.environment.eql?('test')

    mod.page_by_type('summative_questionnaire').count.eql? 10
  end

  # ------------------- Also to add? ---------------------

  # demo content tallies are met (this shouldn’t be necessary for genuine content)
  # count how many things we're expecting - in the data sanity check

  # depends on values are present for modules 2-10
  # order of the modules

  # pages have a parent value

  # training_module needs to have a thumbnail
  # should be validated on the contentful model

  # configurable to check both APIs?

  # does every question have a json object on it that looks right
  # JSON checker could be a different class
end
