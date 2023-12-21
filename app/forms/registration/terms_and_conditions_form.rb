module Registration
  class TermsAndConditionsForm < BaseForm
    attr_accessor :terms_and_conditions_agreed_at

    validates :terms_and_conditions_agreed_at, presence: true

    # @return [Boolean]
    def save
      return false unless valid?

      user.update!(terms_and_conditions_agreed_at: terms_and_conditions_agreed_at)
    end
  end
end
