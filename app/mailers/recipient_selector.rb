module RecipientSelector
    def complete_registration_recipients
        User.training_email_recipients.registration_complete
    end
end