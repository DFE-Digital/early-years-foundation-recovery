module Registration
  class WhereYouLiveForm < BaseForm
    attr_accessor :where_you_live

    validates :where_you_live, presence: true

    # @return [Boolean]
    def save
      return false unless valid?

      country = canonical_where_you_live
      attributes = { country: country }
      attributes[:local_authority] = nil unless england_selected?(country)

      user.update!(attributes)
    end

  private

    # @return [String]
    def canonical_where_you_live
      value = where_you_live.to_s.strip
      location = Trainee::Location.all.find do |candidate|
        candidate.id == value || candidate.name.casecmp(value).zero?
      end

      location&.name || value
    end

    # @param country [String]
    # @return [Boolean]
    def england_selected?(country)
      country.casecmp('England').zero?
    end
  end
end
