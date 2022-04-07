require 'rails_helper'

RSpec.describe Users::SettingForm do
  let(:setting_form) { described_class.new(user: create(:user)) }

  specify 'postcode must be present' do
    setting_form.postcode = ''
    setting_form.validate
    expect(setting_form.errors[:postcode].first).to eq("Enter your setting's postcode.")
  end
end
