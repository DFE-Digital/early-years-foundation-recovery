require 'rails_helper'

RSpec.describe CoercionDecorator do
  describe '.call' do
    

    let(:input) do
      [{
        test_percentage: 0.1,
        date: Time.zone.local(2023, 1, 1),
        array: 1,
      },
      {
        test_percentage: 0.2,
        date: Time.zone.local(2023, 1, 2),
        array: 2,
      },
      {
        test_percentage: 0.3,
        date: Time.zone.local(2023, 1, 3),
        array: 3,
      }
    ]
    end

    let(:formatted_output) do
      [{
        test_percentage: '10.0%',
        date: '2023-01-01 00:00:00',
        array: 1,
      },
        {
            test_percentage: '20.0%',
            date: '2023-01-02 00:00:00',
            array: 2,
        },
        {
            test_percentage: '30.0%',
            date: '2023-01-03 00:00:00',
            array: 3,
        }
    ]
    end

    let(:user) { create(:user, :registered, :agency_setting)}

    let(:formatted_active_record) do
        [
            {
              "closed_at" => user.closed_at,
              "closed_reason" => user.closed_reason,
              "closed_reason_custom" => user.closed_reason_custom,
              "confirmation_sent_at" => user.confirmation_sent_at,
              "confirmation_token" => user.confirmation_token,
              "confirmed_at" => user.confirmed_at.strftime('%Y-%m-%d %H:%M:%S'),
              "created_at" => user.created_at.strftime('%Y-%m-%d %H:%M:%S'),
              "display_whats_new" => user.display_whats_new,
              "early_years_emails" => user.early_years_emails,
              "email" => user.email,
              "encrypted_password" => user.encrypted_password,
              "failed_attempts" => user.failed_attempts,
              "first_name" => user.first_name,
              "id" => user.id,
              "last_name" => user.last_name,
              "local_authority" => user.local_authority,
              "locked_at" => user.locked_at,
              "module_time_to_completion" => user.module_time_to_completion,
              "private_beta_registration_complete" => user.private_beta_registration_complete,
              "registration_complete" => user.registration_complete,
              "remember_created_at" => user.remember_created_at,
              "reset_password_sent_at" => user.reset_password_sent_at,
              "reset_password_token" => user.reset_password_token,
              "role_type" => user.role_type,
              "role_type_other" => user.role_type_other,
              "setting_type" => user.setting_type,
              "setting_type_id" => user.setting_type_id,
              "setting_type_other" => user.setting_type_other,
              "terms_and_conditions_agreed_at" => user.terms_and_conditions_agreed_at.strftime('%Y-%m-%d %H:%M:%S'),
              "training_emails" => user.training_emails,
              "unconfirmed_email" => user.unconfirmed_email,
              "unlock_token" => user.unlock_token,
              "updated_at" => user.updated_at.strftime('%Y-%m-%d %H:%M:%S')
            }
          ]

    end

    before do
        formatted_active_record
    end

    specify { expect(described_class.new.call(input)).to eq(formatted_output) }


    specify { expect(described_class.new.call(User.all)).to eq(formatted_active_record) }
  end
end
