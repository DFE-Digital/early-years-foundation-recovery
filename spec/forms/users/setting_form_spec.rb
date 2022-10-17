require 'rails_helper'

RSpec.describe Users::SettingForm do
  subject(:setting_form) { described_class.new(user: create(:user)) }

  describe 'setting type' do
    it 'must be present' do
      setting_form.setting_type = nil
      setting_form.validate
      expect(setting_form.errors[:setting_type].first).to eq "You need to enter the setting type you work in."
    end
  end
end
