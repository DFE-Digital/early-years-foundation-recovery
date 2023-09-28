module Registration
  class TrainingEmailsForm < BaseForm
    attr_accessor :training_emails

    validates :training_emails, presence: true

    # @return [Boolean]
    def save
      return false unless valid?

      user.update!(training_emails: training_emails)
    end
  end
end
