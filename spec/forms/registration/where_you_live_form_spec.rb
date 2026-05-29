require 'rails_helper'

RSpec.describe Registration::WhereYouLiveForm do
  subject(:form) { described_class.new(user: user) }

  let(:user) { create(:user) }

  xdescribe '#validate' do
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
end