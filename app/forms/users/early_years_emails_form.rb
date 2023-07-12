module Users
  class EarlyYearsEmailsForm < BaseForm
    attr_accessor :early_years_emails

    validates :early_years_emails, presence: true

    def name
      'early_years_emails'
    end

    def save
      if valid?
        user.update!(
          early_years_emails: early_years_emails,
        )
      end
    end
  end
end
