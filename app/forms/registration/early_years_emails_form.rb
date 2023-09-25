module Registration
  class EarlyYearsEmailsForm < BaseForm
    attr_accessor :early_years_emails

    validates :early_years_emails, presence: true

    # @return [Boolean]
    def save
      return false unless valid?

      user.update!(early_years_emails: early_years_emails)
    end
  end
end
