require 'rails_helper'

RSpec.describe PaginationDecorator do
  subject(:decorator) do
    described_class.new(content)
  end

  let(:mod) { Training::Module.by_name(:alpha) }
  let(:content) { mod.page_by_name('1-1-1') }

  it '#heading' do
    expect(decorator.heading).to eq 'The first submodule'
  end

  it '#section_numbers' do
    expect(decorator.section_numbers).to eq 'Section 1 of 4'
  end

  it '#page_numbers' do
    expect(decorator.page_numbers).to eq 'Page 2 of 7'
  end

  it '#percentage' do
    expect(decorator.percentage).to eq '29%'
  end

  describe 'skippable questions' do
    let(:content) { mod.page_by_name('feedback-textarea-only') }

    context 'when answered' do
      before do
        create(:response, question_name: content.name, text_input: 'text input')
      end

      it '#page_numbers' do
        expect(decorator.page_numbers).to eq 'Page 3 of 9'
      end
    end

    context 'when unanswered' do
      it '#page_numbers' do
        expect(decorator.page_numbers).to eq 'Page 3 of 9'
      end
    end
  end

  context 'when handling pre-confidence pages' do
    let(:pre_confidence_intro) do
      obj = Training::Page.allocate
      allow(obj).to receive_messages(
        pre_confidence_intro?: true,
        pre_confidence_question?: false,
        feedback_question?: false,
        section_content: [],
        parent: nil,
      )
      obj
    end
    let(:pre_confidence_question) do
      obj = Training::Page.allocate
      allow(obj).to receive_messages(
        pre_confidence_intro?: false,
        pre_confidence_question?: true,
        feedback_question?: false,
        section_content: [],
        parent: nil,
      )
      obj
    end
    let(:normal_page) do
      obj = Training::Page.allocate
      allow(obj).to receive_messages(
        pre_confidence_intro?: false,
        pre_confidence_question?: false,
        feedback_question?: false,
        section_content: [],
        parent: nil,
      )
      obj
    end
    let(:mod) do
      instance_double(Training::Module,
                      content_sections: {
                        1 => [pre_confidence_intro],
                        2 => [pre_confidence_question],
                        3 => [normal_page],
                      },
                      submodule_count: 3)
    end

    before do
      allow(pre_confidence_intro).to receive(:parent).and_return(mod)
      allow(pre_confidence_question).to receive(:parent).and_return(mod)
      allow(normal_page).to receive_messages(parent: mod, section_content: [pre_confidence_intro, pre_confidence_question, normal_page])
    end

    it 'skips pre-confidence pages in section_numbers' do
      decorator = described_class.new(normal_page)
      expect(decorator.section_numbers).to eq 'Section 1 of 1'
    end

    it 'skips pre-confidence intro pages in section_numbers' do
      decorator = described_class.new(pre_confidence_intro)
      expect(decorator.section_numbers).to be_nil
    end
  end
end
