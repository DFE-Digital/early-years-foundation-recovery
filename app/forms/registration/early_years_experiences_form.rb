module Registration
  class EarlyYearsExperiencesForm < BaseForm
    attr_accessor :early_years_experience

    validates :early_years_experience, presence: true

    def early_years_experiences
      YAML.load_file(Rails.root.join('data/early_years_experience.yml')).map { |hash| OpenStruct.new(hash) }
    end

    # @return [Boolean]
    def save
      return false unless valid?

      user.update!(early_years_experience: early_years_experience)
    end
  end
end
