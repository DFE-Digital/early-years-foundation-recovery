require 'rails_helper'

RSpec.describe Response, :cms, type: :model do
  let(:radio_button_response) { user.responses.create(training_module: 'alpha', question_name: '1-1-4', answer: answer) }
  let(:check_box_response) { user.responses.create(training_module: 'alpha', question_name: '1-2-1-1', answer: answer) }

  let(:user) { create :user, :registered }

  before do
    skip 'WIP' unless Rails.application.cms?
  end

  context 'with radio button' do
    describe 'with no answer' do
      let(:answer) { nil }

      it 'is invalid' do
        expect(radio_button_response).to be_invalid
        expect(radio_button_response.errors.full_messages).to eq ["Answer Please select an answer."]
      end
    end

    describe 'with correct answer' do
      let(:answer) { 1 }

      it 'banner title for successful assessment' do
        expect(radio_button_response.banner_title).to eq("That's right")
      end

      it 'successful assessment summary' do
        expect(radio_button_response.summary).to match(/You selected the correct answers/)
      end
    end

    describe 'with incorrect answer' do
      let(:answer) { 2 }

      it 'banner title for failing assessment' do
        expect(radio_button_response.banner_title).to eq("That's not quite right")
      end

      it 'failure assessment summary' do
        expect(radio_button_response.summary).to match(/You did not select the correct answers/)
      end
    end
  end

  context 'with check box' do
    describe 'with no answer' do
      let(:answer) { nil }

      it 'is invalid' do
        expect(check_box_response).to be_invalid
        expect(check_box_response.errors.full_messages).to eq ["Answer Please select an answer."]
      end
    end

    describe 'with correct answer' do
      let(:answer) { [1, 3] }

      it 'banner title for successful assessment' do
        expect(check_box_response.banner_title).to eq("That's right")
      end

      it 'successful assessment summary' do
        expect(check_box_response.summary).to match(/You selected the correct answers/)
      end
    end

    describe 'with incorrect answer' do
      let(:answer) { [2] }

      it 'banner title for failing assessment' do
        expect(check_box_response.banner_title).to eq("That's not quite right")
      end

      it 'failure assessment summary' do
        expect(check_box_response.summary).to match(/You did not select the correct answers/)
      end
    end
  end
end
