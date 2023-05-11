#
# Transform basic Content schema into RSpec actionable AST
#
#
class ContentTestSchema
  extend Dry::Initializer

  # @!attribute [r] mod
  #   @return [Training::Module]
  option :mod, Types.Instance(Training::Module), required: true

  # @param pass [Boolean] default: true
  # @return [Array<Array>]
  def call(pass: true)
    @pass = pass

    mod.schema.each_with_index.map do |schema, index|
      @index = index
      @slug, @type, @content, @payload = *schema

      next if skip?

      { path: path, text: text, inputs: inputs }
    end
  end

private

  attr_reader :pass, :index, :slug, :type, :content, :payload

  # @return [String]
  def path
    "/modules/#{mod.name}/#{controller}/#{slug}"
  end

  # @return [String]
  def text
    type.match?(/certificate/) ? 'Congratulations!' : content
  end

  # @return [Array<Array>]
  def inputs
    if type.match?(/question/)
      [
        *question_answers, *question_buttons
      ]
    elsif payload[:note]
      [
        [:make_note, 'note-body-field', payload[:note]],
        [:click_on, 'Save and continue'],
      ]
    elsif type.match?(/assessment_intro/)
      [
        [:click_on, 'Start test'],
      ]
    elsif type.match?(/results/)
      [
        [:click_on, results_button],
      ]
    elsif type.match?(/thankyou/)
      [
        [:click_on, 'Finish'],
      ]
    elsif type.match?(/certificate/)
      []
    else
      [
        [:click_on, 'Next'],
      ]
    end
  end

  # @return [String]
  def controller
    case type
    when /question/ then 'questionnaires'
    when /results/ then 'assessment-result'
    else
      'content-pages'
    end
  end

  # @return [String]
  def results_button
    pass ? 'Next' : 'Retake test'
  end

  # @return [Array<Array>]
  def question_buttons
    if next_type.match?(/results/)
      [
        [:click_on, 'Finish test'],
      ]
    elsif type.match?(/summative/)
      [
        [:click_on, 'Save and continue'],
      ]
    elsif type.match?(/formative/)
      [
        [:click_on, 'Next'],
        [:click_on, 'Next'],
      ]
    else
      [
        [:click_on, 'Next'],
      ]
    end
  end

  # @return [Array<Array>]
  def question_answers
    answers = payload[pass ? :correct : :incorrect]

    if pass && type.match?(/confidence/)
      [
        [:choose, field_name(payload[:correct].last)],
      ]
    elsif payload[:correct].one?
      [
        [:choose, field_name(answers.first)],
      ]
    else
      answers.map do |option|
        [:check, field_name(option)]
      end
    end
  end

  # @param option [Integer]
  # @return [String]
  def field_name(option)
    model = ENV['DISABLE_USER_ANSWER'].present? ? 'response' : 'user-answer'
    "#{model}-answers-#{option}-field"
  end

  # @return [String, nil]
  def next_type
    next_schema[1] if next_schema
  end

  # @return [Array, nil]
  def next_schema
    mod.schema[index + 1]
  end

  # @return [Boolean]
  def skip?
    !pass && type.match?(/confidence|thank|certificate/)
  end
end
