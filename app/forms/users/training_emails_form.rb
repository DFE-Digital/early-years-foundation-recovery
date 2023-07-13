module Users
  class TrainingEmailsForm < BaseForm
    attr_accessor :training_emails

    validates :training_emails, presence: true

    def name
      'training_emails'
    end

    def save
      if valid?
        user.update!(
          training_emails: training_emails,
        )
      end
    end
  end
end
