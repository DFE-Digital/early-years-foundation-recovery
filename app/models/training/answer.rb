module Training
  # Used to validate JSON from CMS and build forms
  #
  class Answer < Dry::Struct
    # JSON multi-dimensional array
    # [
    #   ["Wrong 1"],
    #   ["Wrong 2"],
    #   ["Wrong 3"],
    #   ["Wrong 4"],
    #   ["Correct 1", true]
    # ]
    #
    attribute :json, Types::Array.of(Types::Array).default(Types::EMPTY_ARRAY)

    # @return [Boolean]
    def valid?
      options.all? && gteq?(options, 2) && gteq?(correct_answers, 1)
    rescue Dry::Struct::Error
      false
    end

    # @return [Boolean]
    def multi_select?
      gteq?(correct_options, 2)
    end

    # @return [Array<Integer>]
    def correct_answers
      correct_options.map(&:id)
    end

    # @param disabled [Boolean]
    # @param checked [Array<Integer>]
    # @return [Array<Training::Answer::Option>]
    def options(disabled: false, checked: [])
      json.each.with_index(1).map do |(text, value), order|
        Option.new(
          id: order,
          label: text,
          correct: value,
          disabled: disabled,
          checked: checked.include?(order),
        )
      end
    end

  private

    # @return [Array<Training::Answer::Option>]
    def correct_options
      options.select(&:correct)
    end

    # @param collection [Array]
    # @param limit [Integer]
    # @return [Boolean]
    def gteq?(collection, limit)
      collection.size >= limit
    end

    class Option < Dry::Struct
      attribute :id, Types::Strict::Integer
      attribute :label, Types::Strict::String.constrained(min_size: 3)
      attribute :correct, Types::Params::Bool.fallback(false)
      attribute :disabled, Types::Params::Bool.default(false)
      attribute :checked, Types::Params::Bool.default(false)

      alias_method :correct?, :correct
      alias_method :checked?, :checked
      alias_method :disabled?, :disabled
    end
  end
end
