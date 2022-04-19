require 'rails_helper'

RSpec.describe UserAnswer, type: :model do
  let(:user_answer) { create :user_answer }

  # Testing this association to check ActiveHash associations are working
  it 'is associated with a questionnaire' do
    expect(user_answer.questionnaire).to be_a(Questionnaire)
  end
end
