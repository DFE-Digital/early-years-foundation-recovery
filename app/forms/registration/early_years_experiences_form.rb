module Registration
  class EarlyYearsExperiencesForm < BaseForm
    attr_accessor :early_years_experience

    validates :early_years_experience, presence: true

    # @return [Boolean]
    def save
      return false unless valid?

      user.update!(early_years_experience: early_years_experience)
    end
  end
end
