require 'rails_helper'

RSpec.describe 'Page' do
  context 'when user is not authenticated' do
    it { expect(root_path).to have_page_title 'Home page' }

    it { expect(feedback_index_path).to have_page_title 'Feedback' }
    it { expect(feedback_path('feedback-radio-only')).to have_page_title 'feedback-radio-only' }
    it { expect(feedback_path('thank-you')).to have_page_title 'Thank you' }

    it { expect(course_overview_path).to have_page_title 'About training' }
    it { expect(experts_path).to have_page_title 'The experts' }
    it { expect(about_path('alpha')).to have_page_title 'First Training Module' }

    it { expect(new_user_session_path).to have_page_title 'Sign in' }

    it { expect(setting_path('cookie-policy')).to have_page_title 'Cookie policy' }

    it { expect('404').to have_page_title 'Page not found' }
    it { expect('500').to have_page_title 'Service unavailable' }
    it { expect('503').to have_page_title 'Sorry, there is a problem with the service' }

    it { expect(static_path('accessibility-statement')).to have_page_title 'Accessibility statement' }
    it { expect(static_path('new-registration')).to have_page_title 'Update your registration details' }
    it { expect(static_path('other-problems-signing-in')).to have_page_title 'Other problems signing in' }
    it { expect(static_path('promotional-materials')).to have_page_title 'Promotional materials' }
    it { expect(static_path('sitemap')).to have_page_title 'Sitemap' }
    it { expect(static_path('terms-and-conditions')).to have_page_title 'Terms and conditions' }
    it { expect(static_path('wifi-and-data')).to have_page_title 'Free internet, wifi and data resources' }
  end

  context 'when user is authenticated' do
    include_context 'with progress'
    include_context 'with user'

    before do
      create :assessment, :passed, user: user
    end

    it { expect(root_path).to have_page_title('Home page') }
    it { expect(user_path).to have_page_title('My account') }
    it { expect(my_modules_path).to have_page_title('My modules') }
    it { expect(course_overview_path).to have_page_title('About training') }
    it { expect(setting_path('cookie-policy')).to have_page_title('Cookie policy') }

    it { expect(edit_registration_terms_and_conditions_path).to have_page_title('Terms and Conditions') }
    it { expect(edit_registration_name_path).to have_page_title 'About you' }
    it { expect(edit_registration_setting_type_path).to have_page_title('What setting type do you work in?') }
    it { expect(edit_registration_setting_type_other_path).to have_page_title('Where do you work?') }
    it { expect(edit_registration_local_authority_path).to have_page_title('What local authority area do you work in?') }
    it { expect(edit_registration_role_type_path).to have_page_title('Which of the following best describes your role?') }
    it { expect(edit_registration_role_type_other_path).to have_page_title('What is your role?') }

    it { expect(static_path('whats-new')).to have_page_title "What's new in the training" }

    context 'and viewing module content' do
      [
        ['what-to-expect',                'First Training Module : What to expect during the training'],
        ['1-1',                           'First Training Module : The first submodule'],
        ['1-1-1',                         'First Training Module : 1-1-1'],
        ['1-1-2',                         'First Training Module : 1-1-2'],
        ['1-1-3',                         'First Training Module : 1-1-3'],
        ['1-1-3-1',                       'First Training Module : 1-1-3-1'],
        ['1-1-4',                         'First Training Module : 1-1-4'],
        ['1-2',                           'First Training Module : The second submodule'],
        ['1-2-1',                         'First Training Module : 1-2-1'],
        ['1-2-1-1',                       'First Training Module : 1-2-1-1'],
        ['1-2-1-2',                       'First Training Module : 1-2-1-2'],
        ['1-2-1-3',                       'First Training Module : 1-2-1-3'],
        ['1-3',                           'First Training Module : Summary and next steps'],
        ['1-3-1',                         'First Training Module : Recap'],
        ['1-3-2',                         'First Training Module : End of module test'],
        ['1-3-2-1',                       'First Training Module : 1-3-2-1'],
        ['1-3-2-2',                       'First Training Module : 1-3-2-2'],
        ['1-3-2-3',                       'First Training Module : 1-3-2-3'],
        ['1-3-2-4',                       'First Training Module : 1-3-2-4'],
        ['1-3-2-5',                       'First Training Module : 1-3-2-5'],
        ['1-3-2-6',                       'First Training Module : 1-3-2-6'],
        ['1-3-2-7',                       'First Training Module : 1-3-2-7'],
        ['1-3-2-8',                       'First Training Module : 1-3-2-8'],
        ['1-3-2-9',                       'First Training Module : 1-3-2-9'],
        ['1-3-2-10',                      'First Training Module : 1-3-2-10'],
        ['1-3-2-11',                      'First Training Module : Assessment results'],
        ['1-3-3',                         'First Training Module : Reflect on your learning'],
        ['1-3-3-1',                       'First Training Module : 1-3-3-1'],
        ['1-3-3-2',                       'First Training Module : 1-3-3-2'],
        ['1-3-3-3',                       'First Training Module : 1-3-3-3'],
        ['1-3-3-4',                       'First Training Module : 1-3-3-4'],
        ['feedback-intro',                'First Training Module : Additional feedback'],
        ['feedback-radio-only',           'First Training Module : feedback-radio-only'],
        ['feedback-checkbox-only',        'First Training Module : feedback-checkbox-only'],
        ['feedback-textarea-only',        'First Training Module : feedback-textarea-only'],
        ['feedback-radio-other-more',     'First Training Module : feedback-radio-other-more'],
        ['feedback-checkbox-other-more',  'First Training Module : feedback-checkbox-other-more'],
        ['feedback-radio-more',           'First Training Module : feedback-radio-more'],
        ['feedback-checkbox-other-or',    'First Training Module : feedback-checkbox-other-or'],
        ['feedback-skippable',            'First Training Module : feedback-skippable'],
        ['1-3-3-5',                       'First Training Module : Thank you'],
        ['1-3-4',                         'First Training Module : Download your certificate'],
      ].each do |page, title|
        describe "/modules/alpha/content-pages/#{page}" do
          let(:path) do
            training_module_page_path(training_module_id: 'alpha', id: page)
          end

          it { expect(path).to have_page_title(title) }
        end
      end
    end
  end
end
