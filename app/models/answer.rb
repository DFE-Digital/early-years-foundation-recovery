#
# Brett this might be a way to go.
#
class Answer < Dry::Struct
  # Using Hash objects could work thusly, but would be more complex for the content team
  #
  # attribute :options, Types::Array do
  #   attribute :answer, Types::Strict::String
  #   attribute :correct, Types::Params::Bool
  # end

  class Option < Dry::Struct
    attribute :position, Types::Strict::Integer                           # additional build params could be used
    attribute :answer, Types::Strict::String.constrained(min_size: 3)     # checking minimum length is possible
    attribute :correct, (Types::Nil | Types::Params::Bool).default(false) # reduces effort for authors further

    alias_method :correct?, :correct
  end

  # JSON multi-dimensional array
  #
  # Confidence check options:
  # [
  #   ["Strongly agree", true],
  #   ["Agree", true],
  #   ["Neither agree nor disagree", true],
  #   ["Disagree", true],
  #   ["Strongly disagree", true]
  # ]
  #
  # Formative/Summative question options:
  # [
  #   ["Wrong 1"],
  #   ["Wrong 2"],
  #   ["Wrong 3"],
  #   ["Wrong 4"],
  #   ["Correct 1", true]
  # ]
  #
  # has a fallback so the content team can still work in staging when previewing
  attribute :json, Types::Array.of(Types::Array).default(Types::EMPTY_ARRAY)

  # @return [Boolean]
  def valid?
    options.size >= 2 && options.all?
  rescue Dry::Struct::Error
    false
  end

  # @return [Array<Option>]
  def options
    @options ||=
      json.each.with_index(1).map do |(text, value), order|
        Option.new(position: order, answer: text, correct: value)
      end
  end
end
