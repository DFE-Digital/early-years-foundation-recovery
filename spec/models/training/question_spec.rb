require 'rails_helper'

RSpec.describe Training::Question, type: :model do
  subject(:question) do
    # NB: query class is only possible with a page name that is unique
    described_class.find_by(name: '1-1-4-1').first
  end

  describe '#parent' do
    it 'returns the parent module' do
      expect(question.parent).to be_a Training::Module
      expect(question.parent.name).to eq 'alpha'
    end
  end

  describe 'CMS fields' do
    it '#page_type' do
      expect(question.page_type).to eq 'formative_questionnaire'
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

  describe '#legend' do
    context 'when one option is correct' do
      specify do
        expect(question.legend).to end_with '(Select one answer)'
      end
    end

    context 'when the question is a confidence check' do
      subject(:question) do
        Training::Module.by_name('alpha').page_by_name('1-3-3-3')
        # described_class.find_by(name: '1-3-3-3').load.size # => 3
      end

      specify do
        expect(question.legend).to end_with '(Select one answer)'
      end
    end

    context 'when multiple options are correct' do
      subject(:question) do
        Training::Module.by_name('alpha').page_by_name('1-3-2-1')
      end

      specify do
        expect(question.legend).to end_with '(Select all answers that apply)'
      end
    end

    context 'when the question is framed as true or false' do
      subject(:question) do
        Training::Module.by_name('bravo').page_by_name('1-2-1-3')
      end

      specify do
        expect(question.legend).to start_with 'True or false?'
      end
    end
  end
end
