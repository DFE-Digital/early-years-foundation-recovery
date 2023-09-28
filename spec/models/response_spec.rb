require 'rails_helper'

RSpec.describe Response, type: :model do
  before do
    skip unless ENV['DISABLE_USER_ANSWER'].present?
  end

  describe 'dashboard' do
    let(:user) { create :user }
    let(:question) {
      # uncached
      # described_class.find_by(name: , training_module: { name: 'alpha' }).load.first
  
      # cached
      Training::Module.by_name('alpha').page_by_name('1-1-4')
    }

    let(:response) do
      user.response_for(question).tap do |response|
        response.update(answers: [1], correct: true, schema: question.schema)
      end
    end

    let(:headers) do
      %w[id user_id training_module question_name answers archived correct user_assessment_id created_at updated_at schema]
    end

    let(:rows) do
      [response]
    end

    it_behaves_like 'a data export model'
  end
end
