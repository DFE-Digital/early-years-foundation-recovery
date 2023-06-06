module Users
    class DfeEmailPreferenceForm
        attr_accessor :dfe_email_opt_in

        validates :dfe_email_opt_in, presence: true

        def name
            'dfe_email_opt_in'
        end

        def save
                user.update!(
                    dfe_email_opt_in: dfe_email_opt_in,
        end
