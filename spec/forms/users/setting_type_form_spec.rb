require 'rails_helper'

RSpec.describe Users::SettingTypeForm do
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
  end
end
