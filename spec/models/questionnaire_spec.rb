require 'rails_helper'

RSpec.describe Questionnaire, type: :model do
  subject(:questionnaire) do
    described_class.find_by!(name: page_name, training_module: training_module_name)
  end

  #   1: Correct answer 1
  #   2: Wrong answer 1
  #   3: Correct answer 2
  #   4: Wrong answer 2
  let(:page_name) { '1-2-1-3' }

  let(:training_module_name) { 'alpha' }

  it 'is associated with matching module item' do
    module_item = ModuleItem.find_by(training_module: training_module_name, name: page_name)
    expect(questionnaire.module_item).to eq(module_item)
  end

  # describe '#next_button_text' do
  # end

  describe 'validations' do # not currently used
    context 'when unanswered' do
      specify { expect(questionnaire).to be_invalid }
    end

    context 'when answered' do
      context 'and correct' do
        before do
          questionnaire.question_list.first.submit_answers([1, 3])
        end

        specify { expect(questionnaire).to be_valid }
      end

      context 'and incorrect' do
        before do
          questionnaire.question_list.first.submit_answers([2, 4])
        end

        specify { expect(questionnaire).to be_invalid }
      end
    end
  end
end
