module Users
  class TrainingEmailOptInForm < BaseForm
    attr_accessor :training_email_opt_in

    validates :training_email_opt_in, presence: true

    def name
      'training_email_opt_in'
    end

    def save
      if valid?
        user.update!(
          training_email_opt_in: training_email_opt_in,
        )
      end
    end
  end
end
