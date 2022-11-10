require 'rails_helper'

RSpec.describe 'Page' do
  context 'when user is not authenticated' do
    it { expect(root_path).to have_page_title 'Home page' }
    it { expect(new_user_session_path).to have_page_title 'Sign in' }
    it { expect(new_user_password_path).to have_page_title 'Reset password' }
    it { expect(cancel_user_registration_path).to have_page_title 'Create an Early years child development training account' }
    it { expect(new_user_registration_path).to have_page_title 'Create an Early years child development training account' }

    it { expect(setting_path('cookie-policy')).to have_page_title 'Cookie policy' }

    it { expect(static_path('accessibility-statement')).to have_page_title 'Accessibility statement' }
    it { expect(static_path('other-problems-signing-in')).to have_page_title 'Other problems signing in' }
    it { expect(static_path('privacy-policy')).to have_page_title 'Privacy policy' }
    it { expect(static_path('terms-and-conditions')).to have_page_title 'Terms and conditions' }
    it { expect(static_path('whats-new')).to have_page_title "What's new" }

    context 'and is confirmed' do
      let(:user) { create(:user, :confirmed) }

      it 'requesting password reset' do
        token = user.send_reset_password_instructions
        expect(edit_user_password_path(reset_password_token: token)).to have_page_title 'Choose a new password'
      end
    end

    context 'and is unconfirmed' do
      let(:user) { create(:user) }

      it 'is a valid confirmation token' do
        expect(user_confirmation_path(confirmation_token: user.confirmation_token)).to have_page_title 'Sign in'
        expect(page).to have_current_path new_user_session_path
      end

      it { expect(new_user_unlock_path).to have_page_title 'Resend unlock instructions' }

      it 'is a valid unlock token' do
        token = user.lock_access!
        expect(user_unlock_path(unlock_token: token)).to have_page_title 'Sign in'
        expect(page).to have_current_path new_user_session_path
      end

      it 'is an expired/invalid unlock token' do
        user.lock_access!
        expect(user_unlock_path(unlock_token: 'invalid_token')).to have_page_title 'Resend unlock instructions'
      end
    end
  end

  context 'when user is authenticated' do
    include_context 'with progress'
    include_context 'with user'

    it { expect(root_path).to have_page_title('Home page') }
    it { expect(user_path).to have_page_title('My account') }
    it { expect(my_modules_path).to have_page_title('My modules') }
    it { expect(course_overview_path).to have_page_title('About training') }
    it { expect(users_timeout_path).to have_page_title('User timeout') }
    it { expect(setting_path(id: :cookie_policy)).to have_page_title('Cookie policy') }

    it { expect(edit_user_registration_path).to have_page_title('Change your password') }
    it { expect(new_user_confirmation_path).to have_page_title('Resend your confirmation') }

    it { expect(edit_registration_name_path).to have_page_title 'About you' }
    it { expect(edit_registration_setting_type_path).to have_page_title('What setting type do you work in?') }
    it { expect(edit_registration_setting_type_other_path).to have_page_title('Where do you work?') }
    it { expect(edit_registration_local_authority_path).to have_page_title('What local authority area do you work in?') }
    it { expect(edit_registration_role_type_path).to have_page_title('Which of the following best describes your role?') }
    it { expect(edit_registration_role_type_other_path).to have_page_title('What is your role?') }

    it { expect(edit_email_user_path).to have_page_title('Change email address') }
    it { expect(edit_password_user_path).to have_page_title('Change password') }

    it { expect(check_email_confirmation_user_path).to have_page_title('Check email confirmation') }
    it { expect(check_email_password_reset_user_path).to have_page_title('Check email password reset') }

    context 'and viewing module content' do
      [
        ['what-to-expect',    'First Training Module : What to expect during the training'],
        ['before-you-start',  'First Training Module : Before you start'],
        ['intro',             'First Training Module : Introduction'],
        ['1-1',               'First Training Module : The first submodule'],
        ['1-1-1',             'First Training Module : 1-1-1'],
        ['1-1-2',             'First Training Module : 1-1-2'],
        ['1-1-3',             'First Training Module : 1-1-3'],
        ['1-1-3-1',           'First Training Module : 1-1-3-1'],
        ['1-1-4',             'First Training Module : 1-1-4'],
        ['1-2',               'First Training Module : The second submodule'],
        ['1-2-1',             'First Training Module : 1-2-1'],
        ['1-2-1-1',           'First Training Module : 1-2-1-1'],
        ['1-2-1-2',           'First Training Module : 1-2-1-2'],
        ['1-2-1-3',           'First Training Module : 1-2-1-3'],
        ['1-3',               'First Training Module : Summary and next steps'],
        ['1-3-1',             'First Training Module : Recap'],
        ['1-3-2',             'First Training Module : End of module test'],
        ['1-3-2-1',           'First Training Module : 1-3-2-1'],
        ['1-3-2-2',           'First Training Module : 1-3-2-2'],
        ['1-3-2-3',           'First Training Module : 1-3-2-3'],
        ['1-3-2-4',           'First Training Module : 1-3-2-4'],
        ['1-3-2-5',           'First Training Module : Assessment results'],
        ['1-3-3',             'First Training Module : Reflect on your learning'],
        ['1-3-3-1',           'First Training Module : 1-3-3-1'],
        ['1-3-3-2',           'First Training Module : 1-3-3-2'],
        ['1-3-3-3',           'First Training Module : 1-3-3-3'],
        ['1-3-3-4',           'First Training Module : Thank you'],
        ['1-3-4',             'First Training Module : Download your certificate'],
      ].each do |page, title|
        describe "/modules/alpha/content-pages/#{page}" do
          let(:path) do
            training_module_content_page_path(training_module_id: alpha.name, id: page)
          end

          it { expect(path).to have_page_title(title) }
        end
      end
    end
  end
end
