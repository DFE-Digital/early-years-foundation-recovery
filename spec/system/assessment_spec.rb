require 'rails_helper'

RSpec.describe 'Assessment' do
  let (:user) { create :user, :confirmed }
  

  before do
    quiz = AssessmentQuiz.new(user: user, type: 'formative_assessment', training_module_id: training_module.id, name: '')
  end

  context 'when a user has taken a formative assessment' do
    it 'is not able to visit page to retake assessment' do

      
    end

    it 'link cannot be clicked to retake the assessment' do
      visit training_module_path('alpha')
      
      expect(page).to have_no_link(training_module.name)
        .and have_content(training_module.name)
    end
  end

  before do
    quiz = AssessmentQuiz.new(user: user, type: 'summative_assessment', training_module_id: , name: '')
    training_module = 
  end
  
  context 'when a user has taken a summative assessment and failed' do
    it 'is able to retake the assessment' do

      expect(quiz.check_if_assessment_taken).to eq(true)
      expect(quiz.calculate_status).to eq('failed')
    end

    it 'is able to visit page to retake assessment' do
      visit 
    end

    it 'link can be clicked to retake the assessment' do
      visit training_module_path('alpha')
      
      expect(page).to have_link(training_module.name)
    end
  end

  before do
    quiz = AssessmentQuiz.new(user: user, type: 'summative_assessment', training_module_id: , name: '')
    training_module = 
  end

  context 'when a user has taken a summative assessment and passed' do
    it 'is not able to retake the assessment' do

      expect(quiz.check_if_assessment_taken).to eq(true)
      expect(quiz.calculate_status).to eq('passed')
    end

    it 'is able to visit page to retake assessment' do
      visit 
    end

    it 'link can be clicked to retake the assessment' do
      visit training_module_path('alpha')
      
      expect(page).to have_link(training_module.name)
    end
  end
end