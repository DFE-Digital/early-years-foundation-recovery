require 'rails_helper'

RSpec.describe Users::NameForm do
  subject(:form) { described_class.new(user: user) }

  let(:user) { create(:user) }

  describe '#validate' do
    let(:first_name_errors) { form.errors[:first_name] }
    let(:last_name_errors) { form.errors[:last_name] }

    before do
      form.first_name = first_name
      form.last_name = last_name
      form.validate
    end

    context 'without input' do
      let(:first_name) { '' }
      let(:last_name) { '' }

      specify do
        expect(first_name_errors).to be_present
        expect(last_name_errors).to be_present
      end
    end

    context 'with input' do
      let(:first_name) { 'foo' }
      let(:last_name) { 'bar' }

      specify do
        expect(first_name_errors).not_to be_present
        expect(last_name_errors).not_to be_present
      end
    end
  end
end
