require 'rails_helper'

RSpec.describe Training::Question, type: :model do
  subject(:question) do
    # NB: query class is only possible with a page name that is unique
    described_class.find_by(name: '1-1-4-1').first
  end

  it_behaves_like 'updated content', '1-2-1-1'

  describe '#parent' do
    it 'returns the parent module' do
      expect(question.parent).to be_a Training::Module
      expect(question.parent.name).to eq 'alpha'
    end
  end

  describe 'CMS fields' do
    it '#page_type' do
      expect(question.page_type).to eq 'formative'
    end

    it '#answers' do
      expect(question.answers).to eq [
        ['Correct answer 1', true],
        ['Wrong answer 1'],
      ]
    end

    describe '#description' do
      let(:confidence_question) { Training::Module.by_name('alpha').page_by_name('1-3-3-3') }

      it 'returns nil for confidence questions without a description field' do
        expect(confidence_question.description).to be_nil
      end

      it 'returns nil for non-confidence questions' do
        expect(question.description).to be_nil
      end
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

    context 'when the question is a confidence check' do
      subject(:question) do
        Training::Module.by_name('alpha').page_by_name('1-3-3-3')
      end

      after do
        question.instance_variable_set(:@parent, nil)
        question.instance_variable_set(:@answer, nil)
      end

      context 'when the module has pre-confidence questions' do
        before do
          question.instance_variable_set(:@answer, nil)
          module_with_pre_confidence = instance_double(Training::Module, pre_confidence_questions: [double(:pre_confidence_question)]) # rubocop:disable RSpec/VerifiedDoubles
          question.with_parent(module_with_pre_confidence)
        end

        it 'uses confidence-style options' do
          expect(question.options.map(&:label)).to eq([
            'Very confident',
            'Somewhat confident',
            'Neutral',
            'Not very confident',
            'Not confident at all',
          ])
        end
      end

      context 'when the module has no pre-confidence questions' do
        before do
          question.instance_variable_set(:@answer, nil)
          module_without_pre_confidence = instance_double(Training::Module, pre_confidence_questions: [])
          question.with_parent(module_without_pre_confidence)
        end

        it 'uses agree/disagree options' do
          expect(question.options.map(&:label)).to eq([
            'Strongly agree',
            'Agree',
            'Neither agree nor disagree',
            'Disagree',
            'Strongly disagree',
          ])
        end
      end
    end
  end

  it '#correct_answers' do
    expect(question.correct_answers).to eq [1]
  end

  it '#multi_select?' do
    expect(question.multi_select?).to be false
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
      end

      specify do
        expect(question.legend).not_to end_with '(Select one answer)'
        expect(question.legend).to eq question.body.to_s
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

    context 'when the question is a feedback question' do
      subject(:question) do
        Training::Module.by_name('alpha').page_by_name('feedback-radio-only')
      end

      let(:first_option) { question.options.first }

      specify do
        expect(first_option.label).to eq 'Option 1'
      end
    end

    context 'when the question is a feedback free text question' do
      subject(:question) do
        Training::Module.by_name('alpha').page_by_name('feedback-textarea-only')
      end

      specify do
        expect(question.answers).to eq []
      end
    end
  end

  describe '#debug_summary' do
    it 'summarises information' do
      expect(question.debug_summary).to eq(
        <<~SUMMARY,
          uid: 49Z7xDMPfGAnIY8jzyD4ia
          module uid: 6EczqUOpieKis8imYPc6mG
          module name: alpha
          published at: Management Key Missing
          page type: formative

          ---
          previous: 1-1-4
          current: 1-1-4-1
          next: 1-2

          ---
          submodule: 1
          topic: 4

          ---
          position in module: 8th
          position in submodule: 7th
          position in topic: 2nd

          ---
          pages in submodule: 6
          pages in topic: 2
        SUMMARY
      )
    end
  end
end
