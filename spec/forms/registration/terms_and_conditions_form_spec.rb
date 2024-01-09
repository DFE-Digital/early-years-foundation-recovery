require 'rails_helper'

RSpec.describe Registration::TermsAndConditionsForm do
  subject(:form) { described_class.new(user: user) }

  let(:user) { create(:user) }

  describe '#validate' do
    let(:errors) { form.errors[:terms_and_conditions_agreed_at] }

    before do
      form.terms_and_conditions_agreed_at = time
      form.validate
    end

    context 'without input' do
      let(:time) { nil }

      specify do
        expect(errors).to be_present
      end
    end

    context 'with input' do
      let(:time) { Time.zone.now }

      specify do
        expect(errors).not_to be_present
      end
    end
  end
end
