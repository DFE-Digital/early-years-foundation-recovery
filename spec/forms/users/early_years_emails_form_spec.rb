require 'rails_helper'

RSpec.describe Users::EarlyYearsEmailsForm do
  subject(:early_years_email_form) { described_class.new(user: create(:user)) }

  describe 'early years email choice' do
    it 'must be present' do
      early_years_email_form.early_years_emails = nil
      early_years_email_form.validate
      expect(early_years_email_form.errors[:early_years_emails].first).to eq 'Choose an option.'
    end
  end
end
