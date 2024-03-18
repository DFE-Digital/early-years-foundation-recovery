require 'rails_helper'

RSpec.describe FeedbackPaginationDecorator do
  subject(:decorator) do
    described_class.new(content)
  end

  let(:mod) { Training::Module.by_name(:alpha) }
  let(:content) { mod.page_by_name('feedback-radiobutton') }

  it '#heading' do
    expect(decorator.heading).to eq 'Additional feedback'
  end

  it '#section_numbers' do
    expect(decorator.section_numbers).to eq 'Section 3 of 4'
  end

  it '#page_numbers (should skip the one off question)' do
    expect(decorator.page_numbers).to eq 'Page 1 of 8'
  end

  it '#percentage' do
    expect(decorator.percentage).to eq '13%'
  end

  describe 'skippable questions' do
    let(:content) { mod.page_by_name('feedback-freetext') }

    context 'when answered' do
      before do
        create(:response, question_name: content.name, text_input: 'text input')
      end

      it '#page_numbers' do
        expect(decorator.page_numbers).to eq 'Page 3 of 8'
      end
    end

    context 'when unanswered' do
      it '#page_numbers' do
        expect(decorator.page_numbers).to eq 'Page 3 of 8'
      end
    end
  end
end
