require 'rails_helper'

RSpec.describe Users::TrainingEmailOptInForm do
  subject(:training_email_form) { described_class.new(user: create(:user)) }

  describe 'training email choice' do
    it 'must be present' do
      training_email_form.training_email_opt_in = nil
      training_email_form.validate
      expect(training_email_form.errors[:training_email_opt_in].first).to eq 'Choose an option.'
    end
  end
end
