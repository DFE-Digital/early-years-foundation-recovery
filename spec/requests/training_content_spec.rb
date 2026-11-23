require 'rails_helper'

RSpec.describe 'Training content', type: :request do
  before do
    sign_in create(:user, :registered)
  end

  describe 'GET /modules/:training_module_id/content-pages' do
    before do
      get training_module_pages_path(:alpha)
    end

    it 'redirects to first page' do
      expect(response).to redirect_to training_module_page_path(:alpha, 'what-to-expect')
    end
  end

  describe 'GET /modules/:training_module_id/content-pages/:id' do
    before do
      get training_module_page_path(:alpha, page_name)
    end

    context 'when content is a text page' do
      let(:page_name) { 'what-to-expect' }

      it 'renders a template successfully' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when content is a question' do
      let(:page_name) { '1-1-4-1' }

      it 'redirects to questions controller' do
        expect(response).to redirect_to training_module_question_path(:alpha, page_name)
      end
    end
  end

  describe 'GET /modules/:training_module_id/assessment-result/:id' do
    let(:user) { create(:user, :registered) }
    let(:alpha) { Training::Module.by_name(:alpha) }
    let(:attempt) { create :assessment, user: user, started_at: 1.minute.ago }

    before do
      sign_in user
      alpha.summative_questions.each do |question|
        create :response, user: user, assessment: attempt, training_module: 'alpha',
                          question_name: question.name, question_type: 'summative',
                          answers: question.correct_answers
      end
    end

    context 'when the final submission was lost' do
      it 'grades the completed attempt' do
        get training_module_assessment_path(:alpha, alpha.assessment_results_page.name)
        expect(attempt.reload).to have_attributes(score: 100.0, passed: true)
      end
    end

    context 'when an empty duplicate was graded at 0%' do
      before do
        create :assessment, :failed, user: user, started_at: attempt.started_at + 0.005
      end

      it 'grades the answered attempt instead' do
        get training_module_assessment_path(:alpha, alpha.assessment_results_page.name)
        expect(attempt.reload).to have_attributes(score: 100.0, passed: true)
      end
    end
  end

  describe 'taking the end of module test when a concurrent request creates a duplicate attempt' do
    let(:user) { create(:user, :registered) }
    let(:alpha) { Training::Module.by_name(:alpha) }

    before do
      sign_in user
      get training_module_question_path(:alpha, alpha.summative_questions.first.name)
      create :assessment, user: user, started_at: Time.zone.now

      alpha.summative_questions.each do |question|
        get training_module_question_path(:alpha, question.name)
        patch training_module_response_path(:alpha, question.name), params: {
          response: { answers: question.correct_answers, submission_nonce: session[:form_nonce] },
        }
      end
    end

    it 'scores the answers the user gave' do
      expect(AssessmentProgress.new(user: user, mod: alpha)).to have_attributes(score: 100.0, passed?: true)
    end

    it 'shows the result' do
      get training_module_assessment_path(:alpha, alpha.assessment_results_page.name)
      expect(response).to have_http_status(:success)
    end
  end
end
