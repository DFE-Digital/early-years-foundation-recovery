# Validate whether a module's content meets minimum functional requirements
#
class ContentfulDataIntegrity
  extend Dry::Initializer

  option :module_name, Types::String

  # NB: Able to be validated in the CMS editor
  #
  # @return [Hash{Symbol=>String}] valid as upcoming module
  MODULE_VALIDATIONS = {
    criteria: 'Missing criteria',
    # dependent: 'Missing dependent module',
    description: 'Missing description',
    duration: 'Missing duration',
    objective: 'Missing objective',
    position: 'Missing position',
    summary: 'Missing short description',
    threshold: 'Missing assessment threshold percentage',
    # thumbnail: 'Missing thumbnail image',
  }.freeze

  # @return [Hash{Symbol=>String}] valid as released module
  CONTENT_VALIDATIONS = {
    # type
    text: 'Missing text pages',
    video: 'Missing video pages',
    formative: 'Missing formative questions',
    assessment_intro: 'Missing assessment intro page',
    confidence_intro: 'Missing confidence intro page',
    recap: 'Missing recap page',
    summary_intro: 'Missing summary intro page',
    results: 'Missing assessment results page',

    # type and postition
    interruption: 'First page is wrong type',
    submodule: 'Second page is wrong type',
    thankyou: 'Penultimate page is wrong type',
    certificate: 'Last page is wrong type',

    # type and frequency
    summative: 'Insufficient summative questions',
    confidence: 'Insufficient confidence checks',

    # structure of submodule/topic
    submodules: 'Submodules are not consecutive',
    topics: 'Topics are not consecutive',

    parent: 'Pages have wrong parent',
    question_answers: 'Question answers are incorrectly formatted', # TODO: which question?
  }.freeze

  # @return [nil]
  def call
    log '---'
    log "ENV: #{env}"
    log "API: #{api}"
    log "#{module_name.upcase}: " + (valid? ? 'pass' : 'fail')
  end

  # @return [Boolean] Validate modules with content
  def valid?
    (module_results + content_results).all? && mod.pages?
  end

  # @return [Training::Module]
  def mod
    Training::Module.by_name(module_name)
  end

  # @param numbers [Array<Integer>]
  # @return [Boolean] 0, 1, 2, 3, 4...
  def consecutive_integers?(numbers)
    numbers.any? && numbers.first.zero? && numbers.each_cons(2).all? { |a, b| (a + 1).eql?(b) }
  end

  # Decorators ---------------------------------------------------------

  # @return [Boolean]
  def debug?
    (Rails.application.debug? || Rails.application.candidate?) && !valid?
  end

  # @return [Array<String>]
  def errors
    validations.select { |method, message| message unless send("#{method}?") }.values
  end

  # MODULE VALIDATIONS ---------------------------------------------------------

  # # @note The asset could be deleted or unpublished.
  # # @return [Boolean]
  # def thumbnail?
  #   mod.fields[:image].present?
  #   # Unreliable response times prevent this additional check:
  #   # && ContentfulModel::Asset.find(mod.fields[:image].id).present?
  # end

  # @return [Boolean]
  def description?
    mod.fields[:description].present?
  end

  # @return [Boolean]
  def summary?
    mod.fields[:short_description].present?
  end

  # @return [Boolean]
  def objective?
    mod.fields[:objective].present?
  end

  # @return [Boolean]
  def threshold?
    mod.fields[:summative_threshold].present?
  end

  # @return [Boolean]
  def position?
    mod.fields[:position].present?
  end

  # @return [Boolean]
  def duration?
    mod.fields[:duration].present?
  end

  # @return [Boolean]
  def criteria?
    mod.fields[:criteria].present?
  end

  # # @return [Boolean]
  # def dependent?
  #   mod.fields[:position].eql?(1) || mod.fields[:depends_on].present?
  # end

  # CONTENT VALIDATIONS --------------------------------------------------------

  # @return [Boolean] parent on pages set to correct module
  def parent?
    mod.content.all? { |entry| entry.parent.name.eql?(mod.name) }
  end

  # @return [Boolean] submodules increment correctly
  def submodules?
    consecutive_integers? sections.keys
  end

  # @return [Boolean] topics increment correctly
  def topics?
    sections.all? do |_, sub_topics|
      sub_topics.map(&:last).map { |topics| consecutive_integers? Array(topics) }
    end
  end

  # @return [Boolean] first page
  def interruption?
    page_by_type_position(type: 'interruption_page', position: 0)
  end

  # @return [Boolean] second page
  def submodule?
    page_by_type_position(type: 'sub_module_intro', position: 1)
  end

  # @return [Boolean] penultimate page
  def thankyou?
    page_by_type_position(type: 'thankyou', position: -2)
  end

  # @return [Boolean] last page
  def certificate?
    page_by_type_position(type: 'certificate', position: -1)
  end

  # @return [Boolean]
  def text?
    page_by_type_position(type: 'text_page')
  end

  # @return [Boolean]
  def video?
    page_by_type_position(type: 'video_page')
  end

  # @return [Boolean]
  def question_answers?
    mod.questions.all? { |question| question.answer.valid? }
  end

  # @return [Boolean]
  def formative?
    page_by_type_position(type: 'formative_questionnaire')
  end

  # 'Brain development and how children learn' has fewest
  # @return [Boolean] demo modules have fewer questions than genuine content
  def confidence?
    demo? || mod.page_by_type('confidence_questionnaire').count >= 4
  end

  # @return [Boolean] demo modules have fewer questions than genuine content
  def summative?
    demo? || mod.page_by_type('summative_questionnaire').count.eql?(10)
  end

  # @return [Boolean]
  def recap?
    page_by_type_position(type: 'recap_page')
  end

  # @return [Boolean]
  def summary_intro?
    page_by_type_position(type: 'summary_intro')
  end

  # @return [Boolean]
  def assessment_intro?
    page_by_type_position(type: 'assessment_intro')
  end

  # @return [Boolean]
  def confidence_intro?
    page_by_type_position(type: 'confidence_intro')
  end

  # @return [Boolean]
  def results?
    page_by_type_position(type: 'assessment_results')
  end

private

  # @return [Hash{Symbol=>String}]
  def validations
    MODULE_VALIDATIONS.merge(CONTENT_VALIDATIONS)
  end

  # @return [Boolean] content for development and testing
  def demo?
    env.eql?('test')
  end

  # @return [String] preview / delivery
  def api
    ContentfulModel.use_preview_api ? 'preview' : 'delivery'
  end

  # @return [String] master / staging / test
  def env
    ContentfulRails.configuration.environment
  end

  # @return [Hash{Integer=>Array<Integer>}] submodule => submodule topics
  def sections
    mod.content.group_by { |page| [page.submodule, page.topic] }.keys.group_by(&:first)
  end

  # @return [Array<Boolean>] validate module attributes
  def module_results
    validate MODULE_VALIDATIONS
  end

  # @return [Array<Boolean>] validate module content attributes
  def content_results
    return [true] unless mod.pages?

    validate CONTENT_VALIDATIONS
  end

  # @return [Array<Boolean>]
  def validate(validations)
    validations.to_enum.with_index.map do |(method, message), index|
      result = send "#{method}?"
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
end
