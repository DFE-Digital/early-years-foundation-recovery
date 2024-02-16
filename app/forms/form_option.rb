# Build an array of radio button binary options
#
# - opt_in.<field>
# - opt_opt.<field>
#
class FormOption
  extend Dry::Initializer

  # @!attribute [r] field
  #   @return [Symbol]
  param :field, Dry::Types['strict.symbol'], reader: :private

  # @!attribute [r] choice
  #   @return [Boolean]
  option :choice, Dry::Types['strict.bool'], default: -> { true }, reader: :private

  # @param field [Symbol]
  # @return [Array<FormOption>]
  def self.build(field)
    [new(field), new(field, choice: false)]
  end

  # @return [Boolean]
  def id
    choice
  end

  # @return [String]
  def name
    I18n.t (choice ? :opt_in : :opt_out), scope: field
  end
end
