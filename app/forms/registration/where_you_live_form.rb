module Registration
  class WhereYouLiveForm < BaseForm
    attr_accessor :where_you_live

    validates :where_you_live, presence: true

    # @return [Boolean]
    def save
      return false unless valid?

      user.update!(country: where_you_live)
    end
  end
end