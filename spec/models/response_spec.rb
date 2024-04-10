require 'rails_helper'

RSpec.describe Response, type: :model do
  let(:user) { create :user }

  before do
    skip unless Rails.application.migrated_answers?
  end

  describe 'feedback validations' do
    let(:params) do
      {
        training_module: 'alpha',
        correct: true,
        user: user,
        question_type: 'feedback',
      }
    end

    # validate answers array
    describe '#answers' do
      subject(:response) do
        build :response,
              **params,
              question_name: 'feedback-oneoffquestion',
              answers: [1]
      end

      specify { expect(response).to be_valid }
    end

    # validate answers array unless
    # - question options are empty
    # - question hint empty
    #
    describe '#text_input_extra?' do
      subject(:response) do
        build :response,
              **params,
              question_name: 'feedback-freetext',
              answers: [],
              text_input: nil
      end

      specify { expect(response).to be_valid }
    end
  end

  describe 'ToCsv' do
    subject(:response) { user.response_for(question) }

    let(:question) do
      Training::Module.by_name('alpha').page_by_name('1-1-4-1')
    end
    let(:headers) do
      %w[
        id
        user_id
        training_module
        question_name
        answers
        correct
        created_at
        updated_at
        question_type
        assessment_id
        text_input
        visit_id
      ]
    end
    let(:rows) { [response] }

    before do
      response.update!(answers: [1], correct: true)
    end

    it_behaves_like 'a data export model'
  end
end
