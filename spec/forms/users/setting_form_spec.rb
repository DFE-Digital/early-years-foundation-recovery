require 'rails_helper'

RSpec.describe Users::SettingForm do
  let(:setting_form) { described_class.new(user: create(:user)) }

  specify 'postcode must be present' do
    setting_form.postcode = ''
    setting_form.validate
    expect(setting_form.errors[:postcode].first).to eq("Enter your setting's postcode.")
  end

  specify 'ofsted number must be valid' do
    setting_form.ofsted_number = 'foo'
    setting_form.validate
    expect(setting_form.errors[:ofsted_number].first).to eq('This OFSTED number is not recognised')
  end
end
