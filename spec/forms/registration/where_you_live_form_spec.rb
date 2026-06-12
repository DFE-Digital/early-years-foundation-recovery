require 'rails_helper'

RSpec.describe Registration::WhereYouLiveForm do
  subject(:form) { described_class.new(user: user) }

  let(:user) { create(:user) }

  describe '#validate' do
    let(:errors) { form.errors[:where_you_live] }

    before do
      form.where_you_live = input
      form.validate
    end

    context 'without input' do
      let(:input) { '' }

      specify { expect(errors).to be_present }
    end

    context 'with input' do
      let(:input) { 'England' }

      specify { expect(errors).not_to be_present }
    end
  end

  describe '#save' do
    context 'when where_you_live is a lowercase id' do
      before do
        form.where_you_live = 'england'
      end

      it 'stores the canonical country name' do
        expect(form.save).to be(true)

        expect(user.reload.country).to eq 'England'
      end
    end

    context 'when moving outside England' do
      let(:user) { create(:user, local_authority: 'Leeds') }

      before do
        form.where_you_live = 'outside-uk'
      end

      it 'clears local authority' do
        expect(form.save).to be(true)

        expect(user.reload.country).to eq 'Outside the UK'
        expect(user.local_authority).to be_nil
      end
    end

    context 'when selecting England' do
      let(:user) { create(:user, local_authority: 'Leeds') }

      before do
        form.where_you_live = 'england'
      end

      it 'keeps local authority' do
        expect(form.save).to be(true)

        expect(user.reload.country).to eq 'England'
        expect(user.local_authority).to eq 'Leeds'
      end
    end
  end
end
