require 'rails_helper'

RSpec.describe QuestionnaireTaker do
  subject(:service) do
    described_class.new(user: user, questionnaire: questionnaire)
  end

  let(:user) { create :user, :registered }

  # formative
  let(:questionnaire) do
    Questionnaire.find_by!(training_module: :alpha, name: '1-1-4')
  end

  describe '#prepare' do
    it 'returns nil if no answers' do
      expect(service.prepare).to be_nil
    end
  end

  # describe '#populate' do
  # end

  # describe '#persist' do
  # end

  # describe '#archive' do
  # end

  # describe '#existing_user_answers' do
  # end
end
