require 'rails_helper'

RSpec.describe Response, type: :model do
  subject(:response) do
    user.responses.create(
      training_module: 'alpha',
      question_name: question_name,
      answers: answers,
    )
  end

  let(:user) { create :user, :registered }

  context 'with radio buttons' do
    let(:question_name) { '1-1-4' }

    describe 'and no answer' do
      let(:answers) { nil }

      it 'is invalid' do
        expect(response).to be_invalid
        expect(response.errors.full_messages).to eq ['Answers Please select an answer.']
      end
    end

    describe 'and correct answer' do
      let(:answers) { [1] }

      it '#correct?' do
        expect(response).to be_correct
      end

      it '#banner_title' do
        expect(response.banner_title).to eq "That's right"
      end

      it '#summary' do
        expect(response.summary).to match(/You selected the correct answers/)
      end
    end

    describe 'and incorrect answer' do
      let(:answers) { [2] }

      it '#correct?' do
        expect(response).not_to be_correct
      end

      it '#banner_title' do
        expect(response.banner_title).to eq "That's not quite right"
      end

      it '#summary' do
        expect(response.summary).to match(/You did not select the correct answers/)
      end
    end
  end

  context 'with check boxes' do
    let(:question_name) { '1-2-1-1' }

    describe 'and no answer' do
      let(:answers) { nil }

      it 'is invalid' do
        expect(response).to be_invalid
        expect(response.errors.full_messages).to eq ['Answers Please select an answer.']
      end
    end

    describe 'and correct answer' do
      let(:answers) { [1, 3] }

      it '#correct?' do
        expect(response).to be_correct
      end

      it '#banner_title' do
        expect(response.banner_title).to eq "That's right"
      end

      it '#summary' do
        expect(response.summary).to match(/You selected the correct answers/)
      end
    end

    describe 'and incorrect answer' do
      let(:answers) { [2] }

      it '#correct?' do
        expect(response).not_to be_correct
      end

      it '#banner_title' do
        expect(response.banner_title).to eq "That's not quite right"
      end

      it '#summary' do
        expect(response.summary).to match(/You did not select the correct answers/)
      end
    end
  end
end
