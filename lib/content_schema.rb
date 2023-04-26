#
# Happy Path 100% correct
#
# Unhappy Path assessment < 70% correct
#
#
# Transform basic Content schema into Rspec actionable AST
class ContentSchema
  # module name

  def call(pass: true)
    @pass = pass

    mod.schema.each_with_index.map do |schema, index|
      @index = index
      @slug, @type, @content, @payload = *schema

      { path: path, text: text, inputs: inputs }
    end
  end

private

  attr_reader :pass, :index, :slug, :type, :content, :payload

  # @return [String]
  def path
    controller =
      case type
      when /question/ then 'questionnaires'
      when /results/ then 'assessment-result'
      else
        'content-pages'
      end

    "/modules/#{mod.name}/#{controller}/#{slug}"
  end

  # @return [String]
  def text
    type.match?(/certificate/) ? 'Congratulations!' : content.strip
  end

  # @return [Array<Array>]
  def inputs
    if type.match?(/question/)
      [
        *question_answers,
        [:click_on, question_button],
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

  def results_button
    pass ? 'Next' : 'Retake test'
  end

  def question_button
    if next_type.match?(/results/)
      'Finish test'
    elsif type.match?(/summative/)
      'Save and continue'
    else
      'Next'
    end
  end

  def question_answers
    if type.match?(/confidence/)
      [
        [:choose, field_name(payload[:correct].sample)],
      ]
    elsif payload[:correct].one?
      [
        [:choose, field_name(payload[:correct][0])],
      ]
    else
      payload[:correct].map do |option|
        [:check, field_name(option)]
      end
    end
  end

  def field_name(option)
    model = ENV['DISABLE_USER_ANSWER'].present? ? 'response' : 'user-answer'
    "#{model}-answers-#{option}-field"
  end

  # @return [String]
  def next_type
    next_schema[1] if next_schema
  end

  # @return [Array]
  def next_schema
    mod.schema[index + 1]
  end

  def mod
    Training::Module.by_name(:alpha)
  end
end
