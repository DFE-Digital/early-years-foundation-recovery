require 'rails_helper'

RSpec.describe Users::TrainingEmailsForm do
  subject(:form) { described_class.new(user: user) }

  let(:user) { create(:user) }

  describe '#validate' do
    let(:errors) { form.errors[:training_emails] }

    before do
      form.training_emails = input
      form.validate
    end

    context 'without input' do
      let(:input) { '' }

      specify { expect(errors).to be_present }
    end

    context 'with input' do
      let(:input) { 'foo' }

      specify { expect(errors).not_to be_present }
    end
  end
end
