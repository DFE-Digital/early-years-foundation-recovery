require 'rails_helper'

RSpec.describe CoercionDecorator do
  describe '.call' do
    let(:input) do
      [{
        test_percentage: 0.1,
        date: Time.zone.local(2023, 1, 1),
        int: 1,
      },
       {
         test_percentage: 0.2,
         date: Time.zone.local(2023, 1, 2),
         int: 2,
       },
       {
         test_percentage: 0.3,
         date: Time.zone.local(2023, 1, 3),
         int: 3,
       }]
    end

    let(:formatted_output) do
      [{
        test_percentage: '10.0%',
        date: '2023-01-01 00:00:00',
        int: 1,
      },
       {
         test_percentage: '20.0%',
         date: '2023-01-02 00:00:00',
         int: 2,
       },
       {
         test_percentage: '30.0%',
         date: '2023-01-03 00:00:00',
         int: 3,
       }]
    end

    let(:expected_fields) do
      %w[
        closed_at
        closed_reason
        confirmation_token
        confirmed_at
        created_at
        display_whats_new
        email
        encrypted_password
        failed_attempts
        first_name
        id
        last_name
        local_authority
        locked_at
        module_time_to_completion
        private_beta_registration_complete
        registration_complete
        remember_created_at
        reset_password_sent_at
        reset_password_token
        role_type
        setting_type
        terms_and_conditions_agreed_at
        unconfirmed_email
        unlock_token
        updated_at
      ]
    end

    before do
      expected_fields
      create(:user, :registered, created_at: Time.zone.local(2023, 1, 1))
    end

    context 'when input is an array of hashes' do
      it 'formats the dates and percentages' do
        expect(described_class.new.call(input)).to eq(formatted_output)
      end
    end

    context 'when input is an active record collection' do
      it 'formats dates correctly' do
        formatted_users = described_class.new.call(User.all)
        expect(formatted_users.first['created_at']).to eq('2023-01-01 00:00:00')
      end
    end
  end
end
