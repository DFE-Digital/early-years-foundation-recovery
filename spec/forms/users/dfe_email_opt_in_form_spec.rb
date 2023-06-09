require 'rails_helper'

RSpec.describe Users::DfeEmailOptInForm do
  subject(:dfe_email_form) { described_class.new(user: create(:user)) }

  describe 'dfe email choice' do
    it 'must be present' do
      dfe_email_form.dfe_email_opt_in = nil
      dfe_email_form.validate
      expect(dfe_email_form.errors[:dfe_email_opt_in].first).to eq 'Choose an option.'
    end
  end
end
