require 'rails_helper'

RSpec.describe Registration::LocalAuthorityForm do
  subject(:form) { described_class.new(user: user) }

  let(:user) { create(:user) }

  describe '#validate' do
    let(:errors) { form.errors[:local_authority] }

    before do
      form.local_authority = input
      form.validate
    end

    context 'without input' do
      let(:input) { '' }

      specify { expect(errors).to be_present }
    end

    context 'with valid input' do
      let(:input) { 'preschool' }

      specify { expect(errors).not_to be_present }
    end
  end
end
