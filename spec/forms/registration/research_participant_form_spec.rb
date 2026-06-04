require 'rails_helper'

RSpec.describe Registration::ResearchParticipantForm do
  subject(:form) { described_class.new(user: user) }

  let(:user) { create(:user) }

  describe '#validate' do
    let(:errors) { form.errors[:research_participant] }

    before do
      form.research_participant = input
      form.validate
    end

    context 'without input' do
      let(:input) { '' }

      specify { expect(errors).to be_present }
    end

    context 'with input' do
      let(:input) { 'true' }

      specify { expect(errors).not_to be_present }
    end
  end
end
