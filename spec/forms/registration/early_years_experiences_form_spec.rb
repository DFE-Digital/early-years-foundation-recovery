require 'rails_helper'

RSpec.describe Registration::EarlyYearsExperiencesForm do
  subject(:form) { described_class.new(user: user) }

  let(:user) { create(:user) }

  describe '#validate' do
    let(:errors) { form.errors[:early_years_experience] }

    before do
      form.early_years_experience = input
      form.validate
    end

    context 'without input' do
      let(:input) { '' }

      specify { expect(errors).to be_present }
    end

    context 'with input' do
      let(:input) { 'Less than 2 years' }

      specify { expect(errors).not_to be_present }
    end
  end
end
