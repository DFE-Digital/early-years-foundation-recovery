require 'rails_helper'

RSpec::Matchers.define :have_page_title do |expected_page_title|
  match do |path|
    visit path
    page.title.eql? "Child development training : #{expected_page_title}"
  end

  failure_message do |path|
    "expected when visiting #{path} to have title #{expected_page_title}, not #{page.title} "
  end
end

RSpec.describe 'Page' do
  context 'when it is public' do
    it { expect(root_path).to have_page_title('Home page') }
    it { expect(new_user_session_path).to have_page_title('Sign in') }
    it { expect(new_user_password_path).to have_page_title('Reset password') }

    it 'when choosing a new password' do
      user = create :user, :confirmed
      token = user.send_reset_password_instructions
      expect(edit_user_password_path(reset_password_token: token)).to have_page_title('Choose a new password')
    end

    it { expect(cancel_user_registration_path).to have_page_title('Create a child development training account') }
    it { expect(new_user_registration_path).to have_page_title('Create a child development training account') }

    it {
      user = create :user
      expect(user_confirmation_path(confirmation_token: user.confirmation_token)).to have_page_title('Sign in')
    } # valid confirmation redirects to sign in page - no page to show once validated

    it { expect(new_user_unlock_path).to have_page_title('Resend unlock instructions') }

    # valid unlock redirects to sign in page
    it 'and is a valid unlock' do
      user = create :user
      token = user.lock_access!
      expect(user_unlock_path(unlock_token: token)).to have_page_title('Sign in')
    end

    it 'and is an expired/invalid unlock' do
      user = create :user
      user.lock_access!
      expect(user_unlock_path(unlock_token: 'invalid_token')).to have_page_title('Resend unlock instructions')
    end
  end

  context 'when user is logged in' do
    include_context 'with progress'
    include_context 'with user'

    it { expect(root_path).to have_page_title('Home page') }
    it { expect(my_learning_path).to have_page_title('My learning') }
    it { expect(course_overview_path).to have_page_title('About training') }
    it { expect(users_timeout_path).to have_page_title('User timeout') }
    it { expect(setting_path(id: :cookie_policy)).to have_page_title('Cookie policy') }
    it { expect(edit_user_registration_path).to have_page_title('Change your password') }
    it { expect(new_user_confirmation_path).to have_page_title('Resend your confirmation') }
    it { expect(extra_registrations_path).to have_page_title('About you') } # redirects to first step of extra registration, which is name
    it { expect(edit_extra_registration_path(:name)).to have_page_title('About you') }
    it { expect(edit_extra_registration_path(:setting)).to have_page_title('About your setting') }
    it { expect(edit_name_user_path).to have_page_title('Change name') }
    it { expect(edit_email_user_path).to have_page_title('Change email address') }
    it { expect(edit_password_user_path).to have_page_title('Change password') }
    it { expect(edit_postcode_user_path).to have_page_title("Change your setting's postcode information") }
    it { expect(edit_ofsted_number_user_path).to have_page_title("Change your setting's Ofsted number") }
    it { expect(edit_setting_type_user_path).to have_page_title('Change your setting type') }
    it { expect(check_email_confirmation_user_path).to have_page_title('Check email confirmation') }
    it { expect(check_email_password_reset_user_path).to have_page_title('Check email password reset') }
    it { expect(user_path).to have_page_title('My account') }

    context 'and using training module' do
      let(:training_module_id) { 'alpha' }

      it { expect(training_module_content_page_path(training_module_id: training_module_id, id: 'before-you-start')).to have_page_title 'First Training Module : Before you start' }
      it { expect(training_module_content_page_path(training_module_id: training_module_id, id: 'intro')).to have_page_title 'First Training Module : Introduction' }
      it { expect(training_module_content_page_path(training_module_id: training_module_id, id: '1-1')).to have_page_title 'First Training Module : The first submodule' }
      it { expect(training_module_content_page_path(training_module_id: training_module_id, id: '1-1-1')).to have_page_title 'First Training Module : 1-1-1' }
      it { expect(training_module_content_page_path(training_module_id: training_module_id, id: '1-1-2')).to have_page_title 'First Training Module : 1-1-2' }
      it { expect(training_module_content_page_path(training_module_id: training_module_id, id: '1-1-3')).to have_page_title 'First Training Module : 1-1-3' }
      it { expect(training_module_content_page_path(training_module_id: training_module_id, id: '1-1-3-1')).to have_page_title 'First Training Module : 1-1-3-1' }
      it { expect(training_module_questionnaire_path(training_module_id: training_module_id, id: '1-1-4')).to have_page_title 'First Training Module : 1-1-4' }
      it { expect(training_module_content_page_path(training_module_id: training_module_id, id: '1-2')).to have_page_title 'First Training Module : The second submodule' }
      it { expect(training_module_content_page_path(training_module_id: training_module_id, id: '1-2-1')).to have_page_title 'First Training Module : 1-2-1' }
      it { expect(training_module_questionnaire_path(training_module_id: training_module_id, id: '1-2-1-1')).to have_page_title 'First Training Module : 1-2-1-1' }
      it { expect(training_module_content_page_path(training_module_id: training_module_id, id: '1-2-1-2')).to have_page_title 'First Training Module : 1-2-1-2' }
      it { expect(training_module_questionnaire_path(training_module_id: training_module_id, id: '1-2-1-3')).to have_page_title 'First Training Module : 1-2-1-3' }
      it { expect(training_module_content_page_path(training_module_id: training_module_id, id: '1-3')).to have_page_title 'First Training Module : Summary and next steps' }
      it { expect(training_module_content_page_path(training_module_id: training_module_id, id: '1-3-1')).to have_page_title 'First Training Module : Recap' }
      it { expect(training_module_content_page_path(training_module_id: training_module_id, id: '1-3-2')).to have_page_title 'First Training Module : End of module test' }
      it { expect(training_module_questionnaire_path(training_module_id: training_module_id, id: '1-3-2-1')).to have_page_title 'First Training Module : 1-3-2-1' }
      it { expect(training_module_questionnaire_path(training_module_id: training_module_id, id: '1-3-2-2')).to have_page_title 'First Training Module : 1-3-2-2' }
      it { expect(training_module_questionnaire_path(training_module_id: training_module_id, id: '1-3-2-3')).to have_page_title 'First Training Module : 1-3-2-3' }
      it { expect(training_module_questionnaire_path(training_module_id: training_module_id, id: '1-3-2-4')).to have_page_title 'First Training Module : 1-3-2-4' }
      it { expect(training_module_assessment_result_path(training_module_id: training_module_id, id: '1-3-2-5')).to have_page_title 'First Training Module : 1-3-2-5' }
      it { expect(training_module_content_page_path(training_module_id: training_module_id, id: '1-3-3')).to have_page_title 'First Training Module : Reflect on your learning' }
      it { expect(training_module_questionnaire_path(training_module_id: training_module_id, id: '1-3-3-1')).to have_page_title 'First Training Module : 1-3-3-1' }
      it { expect(training_module_questionnaire_path(training_module_id: training_module_id, id: '1-3-3-2')).to have_page_title 'First Training Module : 1-3-3-2' }
      it { expect(training_module_questionnaire_path(training_module_id: training_module_id, id: '1-3-3-3')).to have_page_title 'First Training Module : 1-3-3-3' }
      it { expect(training_module_content_page_path(training_module_id: training_module_id, id: '1-3-3-4')).to have_page_title 'First Training Module : Thank you' }

      it {
        view_whole_module(alpha)
        expect(training_module_certificate_path(training_module_id: training_module_id)).to have_page_title('First Training Module : certificate')
      }

      it { expect(training_module_path(:alpha)).to have_page_title('First Training Module : before-you-start-heading') }
    end

    it { expect(static_path(id: 'accessibility-statement')).to have_page_title('Accessibility statement') }
    it { expect(static_path(id: 'other-problems-signing-in')).to have_page_title('Other problems signing in') }
    it { expect(static_path(id: 'privacy-policy')).to have_page_title('Privacy policy') }
    it { expect(static_path(id: 'terms-and-conditions')).to have_page_title('Terms and conditions') }
  end
end
