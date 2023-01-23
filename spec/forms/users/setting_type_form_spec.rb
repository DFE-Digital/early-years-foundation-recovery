require 'rails_helper'

RSpec.describe Users::SettingTypeForm, :vcr do
  subject(:setting_type_form) { described_class.new(user: create(:user)) }

  describe 'setting type' do
    it 'must be present' do
      setting_type_form.setting_type_id = nil
      setting_type_form.validate
      expect(setting_type_form.errors[:setting_type_id].first).to eq 'Enter the setting type you work in.'
    end

    it 'must be in list' do
      setting_type_form.setting_type_id = 'wrong'
      setting_type_form.validate
      expect(setting_type_form.errors[:setting_type_id].first).to eq 'Enter the setting type you work in.'
    end

    # rubocop:disable Rails/SaveBang
    it 'must maintain consistency with existing users' do
      user = create(:user, :registered, setting_type_id: 'childminder_independent', local_authority: 'Cambridgeshire County Council', role_type: 'Childminder')
      form = described_class.new(user: user, setting_type_id: 'department_for_education')

      form.save
      expect(user.setting_type).to eq('Department for Education')
      expect(user.local_authority).to eq('Not applicable')
      expect(user.role_type).to eq('Not applicable')
    end
    # rubocop:enable Rails/SaveBang
  end
end
