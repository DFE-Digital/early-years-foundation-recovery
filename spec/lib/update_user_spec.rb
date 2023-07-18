require 'rails_helper'
require 'update_user'

RSpec.describe UpdateUser do
  subject(:update_user) do
    Class.new { extend UpdateUser }
  end

  describe '.update_email_preferences' do
    before do
      create(:user, :registered, email: 'test1@example.com')
      create(:user, :registered, email: 'test2@example.com')
      create(:user, :registered, :emails_opt_in, email: 'test3@example.com')
    end

    context 'when given a list of email addresses' do
      it 'the user training and early years email preferences are set to false' do
        email_1 = 'test1@example.com'
        email_2 = 'test2@example.com'
        update_user.email_preferences_unsubscribe([email_1, email_2])
        expect(User.find_by(email: email_1).training_emails).to eq(false)
        expect(User.find_by(email: email_2).training_emails).to eq(false)
      end
    end

    context 'when given an email address that does not exist' do
      it 'outputs a message to the console' do
        email = 'does-not-exist.com'
        expect { update_user.email_preferences_unsubscribe([email]) }.to output("No user found with email: #{email}\n").to_stdout
      end
    end

    context 'when a user already has recorded email preferences' do
      it 'the user is not updated' do
        email_3 = 'test3@example.com'
        update_user.email_preferences_unsubscribe([email_3])
        expect(User.find_by(email: email_3).training_emails).to eq(true)
      end
    end
  end
end
