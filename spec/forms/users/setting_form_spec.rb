require 'rails_helper'

RSpec.describe Users::SettingForm do
  subject(:setting_form) { described_class.new(user: create(:user)) }

  describe 'postcode' do
    it 'must be valid' do
      setting_form.postcode = 'foo'
      setting_form.validate
      expect(setting_form.errors[:postcode].first).to eq "Enter your setting's postcode."
    end
  end

  describe 'ofsted_number' do
    it 'is optional' do
      setting_form.validate
      expect(setting_form.errors[:ofsted_number]).to be_empty
    end

    it 'must be valid' do
      setting_form.ofsted_number = 'foo'
      setting_form.validate
      expect(setting_form.errors[:ofsted_number].first).to eq 'This Ofsted number is not recognised.'
    end
  end
end
