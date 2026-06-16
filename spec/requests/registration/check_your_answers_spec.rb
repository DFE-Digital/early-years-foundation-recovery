require 'rails_helper'

RSpec.describe 'Registration check your answers', type: :request do
  subject(:user) do
    create :user, :named,
           country: 'England',
           setting_type_id: 'nursery_private',
           setting_type: 'Private nursery',
           local_authority: 'Leeds',
           role_type: 'Student',
           early_years_experience: '2-5',
           training_emails: true,
           research_participant: true,
           registration_complete: false
  end

  before { sign_in user }

  describe 'GET /registration/check-your-answers/edit' do
    it 'returns http success and shows the recorded answers' do
      get edit_registration_check_your_answers_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Check your answers')
        .and include(user.name)
        .and include('Leeds')
        .and include('Student')
    end
  end

  describe 'PATCH /registration/check-your-answers (confirm)' do
    it 'completes registration' do
      patch registration_check_your_answers_path
      expect(user.reload.registration_complete).to be true
      expect(response).to redirect_to my_modules_path
    end
  end

  # Scenario 1: change "Where you live" from England to any other option
  describe 'changing where you live from England to elsewhere' do
    it 'removes the local authority and returns to check your answers' do
      patch registration_where_you_live_path, params: {
        return_to: 'check_your_answers',
        user: { where_you_live: 'scotland' },
      }

      expect(user.reload.local_authority).to be_nil
      expect(response).to redirect_to edit_registration_check_your_answers_path
    end
  end

  # Scenario 3: change "Where you live" from elsewhere to England
  describe 'changing where you live from elsewhere to England' do
    subject(:user) do
      create :user, :named,
             country: 'Scotland',
             setting_type_id: 'nursery_private',
             setting_type: 'Private nursery',
             local_authority: nil,
             role_type: 'Student',
             early_years_experience: '2-5',
             training_emails: true,
             research_participant: true,
             registration_complete: false
    end

    it 'asks for the local authority then returns to check your answers' do
      patch registration_where_you_live_path, params: {
        return_to: 'check_your_answers',
        user: { where_you_live: 'england' },
      }
      expect(response).to redirect_to edit_registration_local_authority_path

      patch registration_local_authority_path, params: {
        user: { local_authority: 'Leeds' },
      }
      expect(user.reload.local_authority).to eq('Leeds')
      expect(response).to redirect_to edit_registration_check_your_answers_path
    end
  end

  # Scenario 2: change setting type to an early years related job
  describe 'changing setting type to one that needs setting details' do
    subject(:user) do
      create :user, :named,
             country: 'England',
             setting_type_id: 'other',
             setting_type: 'other',
             setting_type_other: 'Parent or carer',
             local_authority: I18n.t(:na),
             role_type: I18n.t(:na),
             early_years_experience: nil,
             training_emails: true,
             research_participant: true,
             registration_complete: false
    end

    it 'walks through local authority, role and experience before returning' do
      patch registration_setting_type_path, params: {
        return_to: 'check_your_answers',
        user: { setting_type_id: 'nursery_private' },
      }
      expect(response).to redirect_to edit_registration_local_authority_path

      patch registration_local_authority_path, params: {
        user: { local_authority: 'Leeds' },
      }
      expect(response).to redirect_to edit_registration_role_type_path

      patch registration_role_type_path, params: {
        user: { role_type: 'Student' },
      }
      expect(response).to redirect_to edit_registration_early_years_experience_path

      patch registration_early_years_experience_path, params: {
        user: { early_years_experience: '0-2' },
      }
      expect(response).to redirect_to edit_registration_check_your_answers_path
    end
  end

  # Scenario 2 (reported bug): a setting with no role -> a setting that needs
  # role + experience must collect both and show them on the summary.
  describe 'changing from a no-role setting to a role+experience setting' do
    subject(:user) do
      create :user, :named,
             country: 'Outside the UK',
             setting_type_id: 'department_for_education',
             setting_type: 'Department for Education',
             local_authority: I18n.t(:na),
             role_type: I18n.t(:na),
             early_years_experience: nil,
             training_emails: true,
             research_participant: false,
             registration_complete: false
    end

    it 'asks role then experience and shows both on the summary' do
      patch registration_setting_type_path, params: {
        return_to: 'check_your_answers',
        user: { setting_type_id: 'childminder_independent' },
      }
      expect(response).to redirect_to edit_registration_role_type_path

      patch registration_role_type_path, params: {
        user: { role_type: 'Childminder' },
      }
      expect(response).to redirect_to edit_registration_early_years_experience_path

      patch registration_early_years_experience_path, params: {
        user: { early_years_experience: '2-5' },
      }
      expect(response).to redirect_to edit_registration_check_your_answers_path

      expect(user.reload.early_years_experience).to eq('2-5')

      get edit_registration_check_your_answers_path
      expect(response.body).to include('Between 2 and 5 years')
    end
  end

  # Reverse of scenario 2: changing to a setting that needs no role/experience
  # should clear the old answers and return straight to the summary.
  describe 'changing setting type to one that needs no extra details' do
    it 'clears role and experience and returns to check your answers' do
      patch registration_setting_type_path, params: {
        return_to: 'check_your_answers',
        user: { setting_type_id: 'department_for_education' },
      }

      expect(response).to redirect_to edit_registration_check_your_answers_path
      expect(user.reload.role_type).to eq(I18n.t(:na))
      expect(user.early_years_experience).to be_nil

      get edit_registration_check_your_answers_path
      expect(response.body).not_to include('Time worked in early years')
    end
  end

  # A change that unlocks nothing new should bounce straight back.
  describe 'changing a field that unlocks no new questions' do
    it 'returns to check your answers immediately' do
      patch registration_name_path, params: {
        return_to: 'check_your_answers',
        user: { first_name: 'Casey', last_name: 'Jones' },
      }

      expect(user.reload.first_name).to eq('Casey')
      expect(response).to redirect_to edit_registration_check_your_answers_path
    end
  end
end
