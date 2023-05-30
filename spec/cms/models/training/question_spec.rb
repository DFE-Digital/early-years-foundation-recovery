require 'rails_helper'

RSpec.describe Training::Question, :cms, type: :model do
  subject(:question) do
    # uncached
    # described_class.find_by(name: , training_module: { name: 'alpha' }).load.first

    # cached
    Training::Module.by_name('alpha').page_by_name('1-1-4')
  end

  before do
    skip 'WIP' unless Rails.application.cms?
  end

  describe 'CMS fields' do
    it '#page_type' do
      expect(question.page_type).to eq 'formative_questionnaire'
    end

    it '#submodule' do
      expect(question.submodule).to eq 1
    end

    it '#topic' do
      expect(question.topic).to eq 4
    end

    it '#answers' do
      expect(question.answers).to eq [
        ['Correct answer 1', true],
        ['Wrong answer 1'],
      ]
    end
  end

  describe '#options' do
    let(:first_option) { question.options.first }
    let(:last_option) { question.options.last }

    it '#options' do
      expect(question.options.count).to eq(2)

      expect(first_option.label).to eq 'Correct answer 1'
      expect(first_option.id).to eq 1
      expect(first_option.correct?).to be true

      expect(last_option.label).to eq 'Wrong answer 1'
      expect(last_option.id).to eq 2
      expect(last_option.correct?).to be false
    end
  end

  it '#correct_answers' do
    expect(question.correct_answers).to eq [1]
  end

  it '#multi_select?' do
    expect(question.multi_select?).to be false
  end

  it '#assessments_type' do
    expect(question.assessments_type).to eq 'formative_assessment'
  end
end
