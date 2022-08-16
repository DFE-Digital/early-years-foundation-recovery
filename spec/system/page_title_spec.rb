require 'rails_helper'

def has_title(expected_title)
  yield
  expect(page).to have_title("Child development training : #{expected_title}")
end

RSpec.describe 'Page' do
  context 'when it is public' do
    it { has_title('Home page') { visit root_path } }
    it { has_title('Sign in') { visit new_user_session_path } }
    it { has_title('Reset password') { visit new_user_password_path } }

    it 'when choosing a new password' do
      user = create :user, :confirmed
      token = user.send_reset_password_instructions
      has_title('Choose a new password') { visit edit_user_password_path + "?reset_password_token=#{token}" }
    end

    it { has_title('Create a child development training account') { visit new_user_registration_path } }
    it { has_title('Create a child development training account') { visit cancel_user_registration_path } } # redirects

    it {
      has_title('Sign in') do
        user = create :user
        visit user_confirmation_path(confirmation_token: user.confirmation_token)
      end
    } # valid confirmation redirects to sign in page - no page to show once validated

    it { has_title('Resend unlock instructions') { visit new_user_unlock_path } }

    # valid unlock redirects to sign in page
    it "and is a valid unlock" do
      has_title('Sign in') do
        user = create :user
        token = user.lock_access!
        visit user_unlock_path(unlock_token: token)
      end
    end

    it "and is an expired/invalid unlock" do
      has_title('Resend unlock instructions') do
        user = create :user
        user.lock_access!
        visit user_unlock_path(unlock_token: 'invalid_token')
      end
    end
  end

  context 'when user is logged in' do
    include_context 'with user'

    it { has_title('Home page') { visit root_path } }
    it { has_title('My learning') { visit my_learning_path } }
    it { has_title('About training') { visit course_overview_path } }
    it { has_title('User timeout') { visit users_timeout_path } }
    it { has_title('Cookie policy') { visit setting_path(id: :cookie_policy) } }
    it { has_title('Change your password') { visit edit_user_registration_path } }
    it { has_title('Resend your confirmation') { visit new_user_confirmation_path } }
    it { has_title('About you') { visit extra_registrations_path } } # redirects to first step of extra registration, which is name
    it { has_title('About you') { visit edit_extra_registration_path(:name) } }
    it { has_title('About your setting') { visit edit_extra_registration_path(:setting) } }
    it { has_title('Change name') { visit edit_name_user_path } }
    it { has_title('Change email address') { visit edit_email_user_path } }
    it { has_title('Change password') { visit edit_password_user_path } }
    it { has_title("Change your setting's postcode information") { visit edit_postcode_user_path } }
    it { has_title("Change your setting's Ofsted number") { visit edit_ofsted_number_user_path } }
    it { has_title('Check email confirmation') { visit check_email_confirmation_user_path } }
    it { has_title('Check email password reset') { visit check_email_password_reset_user_path } }
    it { has_title('My account') { visit user_path } }

    context 'and using training module' do
      let(:training_module_id) { 'alpha' }

      it { has_title('First Training Module') { visit training_module_content_pages_path(training_module_id: training_module_id) } }
      it { has_title('First Training Module') { visit training_module_content_page_path(training_module_id: training_module_id, id: 'before-you-start') } }
      # TODO: How to set up questionnaire?
      # it { has_title('First Training Module') { visit training_module_questionnaire_path(training_module_id: training_module_id, id: 'before-you-start') } }
      it { has_title('First Training Module') { visit training_module_formative_assessment_path(training_module_id: training_module_id, id: '1-1-4') } }
      it { has_title('First Training Module') { visit training_module_confidence_check_path(training_module_id: training_module_id, id: '1-3-3-1') } }
      it { has_title('Assessments results') { visit training_module_assessments_result_path(training_module_id: training_module_id, id: '1-3-2-5') } }
      it { has_title('End of module test') { visit training_module_retake_quiz_path(training_module_id: training_module_id) } }

      it {
        ahoy = Ahoy::Tracker.new(user: user, controller: 'content_pages')
        # viewing the last page of the module
        ahoy.track('module_content_page', {
          id: '1-3-3-4', # last page of alpha module
          action: 'show',
          controller: 'content_pages',
          training_module_id: training_module_id,
        })
        user.save!
        has_title('First Training Module') { visit training_module_certificate_path(training_module_id: training_module_id) }
      }

      it { has_title('First Training Module') { visit training_module_path(:alpha) } }
    end

    it { has_title('Accessibility statement') { visit static_path(id: 'accessibility-statement') } }
    it { has_title('Other problems signing in') { visit static_path(id: 'other-problems-signing-in') } }
    it { has_title('Privacy policy') { visit static_path(id: 'privacy-policy') } }
    it { has_title('Terms and conditions') { visit static_path(id: 'terms-and-conditions') } }
  end
end
