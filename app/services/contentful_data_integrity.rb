# Validate whether a module's content meets minimum functional requirements
#
class ContentfulDataIntegrity
  extend Dry::Initializer

  option :module_name, Types::String.enum(*Training::Module.ordered.map(&:name))

  MODULE_VALIDATIONS = {
    # presence and volume
    thumbnail?: 'Missing thumbnail',
  }.freeze

  CONTENT_VALIDATIONS = {
    # position and type
    first?: 'First page is wrong type',             # interruption_page
    second?: 'Second page is wrong type',           # sub_module_intro
    penultimate?: 'Penultimate page is wrong type', # thankyou
    last?: 'Last page is wrong type',               # certificate

    # presence and volume
    video?: 'Missing video pages',
    results?: 'Missing assessment results page',
    assessment?: 'Insufficient assessment questions',

    # structure of submodule/topic
    submodules?: 'Submodules are not consecutive',
    topics?: 'Topics are not consecutive',

    parent?: 'Pages have wrong parent',
  }.freeze

  # ------------------- COMBINED ---------------------

  # Validate modules with content
  #
  #
  def call
    log '---'
    log 'ENV: ' + ContentfulRails.configuration.environment
    log 'API: ' + (ContentfulRails.configuration.enable_preview_domain ? 'preview' : 'delivery')
    log "#{module_name.upcase}: " + (valid? ? 'pass' : 'fail')
  end

  # @return [Boolean] Validate modules with content
  def valid?
    (module_results + content_results).all?
  end

  # ------------------- MODULE ---------------------

  # @return [Boolean]
  def thumbnail?
    mod.fields[:image].present?
  end

  # ------------------- CONTENT ---------------------

  # @return [Boolean]
  def video?
    page_by_type_position(type: 'video_page')
  end

  # @return [Boolean]
  def results?
    page_by_type_position(type: 'assessment_results')
  end

  # @return [Boolean]
  def first?
    page_by_type_position(type: 'interruption_page', position: 0)
  end

  # @return [Boolean]
  def second?
    page_by_type_position(type: 'sub_module_intro', position: 1)
  end

  # @return [Boolean]
  def penultimate?
    page_by_type_position(type: 'thankyou', position: -2)
  end

  # @return [Boolean]
  def last?
    page_by_type_position(type: 'certificate', position: -1)
  end

  # @return [Boolean]
  def assessment?
    return true if ContentfulRails.configuration.environment.eql?('test')

    mod.page_by_type('summative_questionnaire').count.eql? 10
  end

  # @return [Boolean]
  def parent?
    mod.content.all? { |entry| entry.parent.name.eql?(mod.name) }
  end

  # @return [Boolean]
  def submodules?
    consecutive_integers? sections.keys
  end

  # @return [Boolean]
  def topics?
    sections.all? do |_, sub_topics|
      sub_topics.map(&:last).map { |topics| consecutive_integers? Array(topics) }
    end
  end

  # ------------------- PRIVATE ---------------------
private

  # @return [Hash{Integer=>Array<Integer>}] submodule => submodule topics
  def sections
    mod.content.group_by { |page| [page.submodule, page.topic] }.keys.group_by(&:first)
  end

  def mod
    @mod ||= Training::Module.by_name(module_name)
  end

  # ------------------- Correct page order ---------------------

  # @param numbers [Array<Integer>]
  # @return [Boolean] 0, 1, 2, 3, 4...
  def consecutive_integers?(numbers)
    numbers.first.zero? && numbers.each_cons(2).all? { |a, b| (a + 1).eql?(b) }
  end

  # @return [Array<Boolean>]
  def module_results
    validate MODULE_VALIDATIONS
  end

  # @return [Array<Boolean>]
  def content_results
    return [true] if mod.content.none? # mod.draft? (self-referential)

    validate CONTENT_VALIDATIONS
  end

  # @return [Array<Boolean>]
  def validate(validations)
    validations.to_enum.with_index.map do |(method, message), index|
      result = send(method)
      log 'ISSUES:' if index.zero? && !result
      log "  - #{message}" unless result
      result
    end
  end

  # @return [String]
  def log(message)
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    else
      puts message
    end
  end

  def page_by_type_position(type:, position: nil)
    return mod.content.map(&:page_type).any?(type) unless position

    mod.content[position].page_type.eql?(type)
  rescue NoMethodError
    false
  end

  # ------------------- Also to add? ---------------------

  # demo content tallies are met (this shouldn’t be necessary for genuine content)
  # count how many things we're expecting - in the data sanity check

  # depends on values are present for modules 2-10
  # order of the modules

  # does every question have a json object on it that looks right
  # JSON checker could be a different class
end
