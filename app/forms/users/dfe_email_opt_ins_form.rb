module Users
    class DfeEmailOptInsForm < BaseForm
        attr_accessor :dfe_email_opt_in

        validates :dfe_email_opt_in, presence: true

        def name
            'dfe_email_opt_in'
        end

        def save
            if valid?
                user.update!(
                    dfe_email_opt_in: dfe_email_opt_in)
            end
        end
    end
end


