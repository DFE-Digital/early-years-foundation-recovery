require 'rails_helper'

RSpec.describe Registration::SettingTypeForm do
  subject(:form) { described_class.new(user: user) }

  describe '#validate' do
    let(:user) { create(:user) }
    let(:errors) { form.errors[:setting_type_id] }

    before do
      form.setting_type_id = input
      form.validate
    end

    context 'without input' do
      let(:input) { '' }

      specify { expect(errors).to be_present }
    end

    context 'with invalid input' do
      let(:input) { 'university' }

      specify { expect(errors).to be_present }
    end

    context 'with valid input' do
      let(:input) { 'preschool' }

      specify { expect(errors).not_to be_present }
    end
  end

  describe '#save' do
    let(:user) do
      create :user, :independent_childminder,
             local_authority: 'Cambridgeshire County Council'
    end

    before do
      form.setting_type_id = 'department_for_education'
      form.save
    end

    it 'updates user details' do
      expect(user.setting_type_id).to eq 'department_for_education'
      expect(user.setting_type).to eq 'Department for Education'
      expect(user.local_authority).to eq 'Not applicable'
      expect(user.role_type).to eq 'Not applicable'
    end
  end
end
