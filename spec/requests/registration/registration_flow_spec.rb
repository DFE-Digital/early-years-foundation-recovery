require 'rails_helper'

# Setting type matrix (see data/setting-type.yml):
#   nursery_private        local_authority: true,  role: other      (LA + role)
#   local_authority        local_authority: true,  role: none       (LA, no role)
#   department_for_education local_authority: false, role: none      (no LA, no role)
#   childminder_independent local_authority: true,  role: childminder
#
RSpec.describe 'Registration journey flows', type: :request do
  subject(:user) { create(:user, :named) }

  before { sign_in user }

  # Choose a setting type and follow the redirect chain to the end.
  def choose_setting(id)
    patch registration_setting_type_path, params: { user: { setting_type_id: id } }
  end

  describe 'England + early years role setting (local authority, role, experience)' do
    subject(:user) { create(:user, :named, country: 'England') }

    it 'asks LA, role and experience before the preference steps' do
      choose_setting('nursery_private')
      expect(response).to redirect_to edit_registration_local_authority_path

      patch registration_local_authority_path, params: { user: { local_authority: 'Leeds' } }
      expect(response).to redirect_to edit_registration_role_type_path

      patch registration_role_type_path, params: { user: { role_type: 'Student' } }
      expect(response).to redirect_to edit_registration_early_years_experience_path

      patch registration_early_years_experience_path, params: { user: { early_years_experience: '2-5' } }
      expect(response).to redirect_to edit_registration_training_emails_path

      patch registration_training_emails_path, params: { user: { training_emails: true } }
      expect(response).to redirect_to edit_registration_research_participant_path

      patch registration_research_participant_path, params: { user: { research_participant: true } }
      expect(response).to redirect_to edit_registration_check_your_answers_path
    end
  end

  describe 'England + non early years role setting (local authority, no role)' do
    subject(:user) { create(:user, :named, country: 'England') }

    it 'asks LA then skips role and experience' do
      choose_setting('local_authority')
      expect(response).to redirect_to edit_registration_local_authority_path

      patch registration_local_authority_path, params: { user: { local_authority: 'Leeds' } }
      expect(response).to redirect_to edit_registration_training_emails_path
    end
  end

  describe 'England + setting with no local authority and no role (e.g. parent/carer/unemployed)' do
    subject(:user) { create(:user, :named, country: 'England') }

    it 'goes straight to the email preference step' do
      choose_setting('department_for_education')
      expect(response).to redirect_to edit_registration_training_emails_path
    end
  end

  describe 'Outside England + early years role setting' do
    subject(:user) { create(:user, :named, country: 'Scotland') }

    it 'asks role and experience but never local authority' do
      choose_setting('childminder_independent')
      expect(response).to redirect_to edit_registration_role_type_path

      patch registration_role_type_path, params: { user: { role_type: 'Childminder' } }
      expect(response).to redirect_to edit_registration_early_years_experience_path

      patch registration_early_years_experience_path, params: { user: { early_years_experience: '0-2' } }
      expect(response).to redirect_to edit_registration_training_emails_path
    end
  end

  describe 'Outside England + setting with no role (e.g. parent/carer/unemployed)' do
    subject(:user) { create(:user, :named, country: 'Scotland') }

    it 'goes straight to the email preference step' do
      choose_setting('department_for_education')
      expect(response).to redirect_to edit_registration_training_emails_path
    end
  end

  describe 'confirming on the check your answers page' do
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

    it 'completes registration and lands on my modules' do
      patch registration_check_your_answers_path
      expect(user.reload.registration_complete).to be true
      expect(response).to redirect_to my_modules_path
    end
  end
end
