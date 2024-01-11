require 'rails_helper'

RSpec.describe Registration::RoleTypeForm do
  subject(:form) { described_class.new(user: user) }

  describe '#validate' do
    let(:user) { create(:user) }

    let(:errors) { form.errors[:role_type] }

    before do
      form.role_type = input
      form.validate
    end

    context 'without input' do
      let(:input) { '' }

      specify { expect(errors).to be_present }
    end

    context 'with valid input' do
      let(:input) { 'trainee' }

      specify { expect(errors).not_to be_present }
    end
  end
end
