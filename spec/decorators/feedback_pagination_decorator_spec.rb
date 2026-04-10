require 'rails_helper'

RSpec.describe FeedbackPaginationDecorator do

  let(:mock_contentful) { MockContentfulService.new }
  let(:user) { create :user }
  let(:mod) { mock_contentful.find('alpha') }
  let(:content) { OpenStruct.new(name: 'feedback-radio-only', page_type: 'feedback', title: 'Feedback Radio Only') }

  before do
    allow(Training::Module).to receive(:by_name).and_return(mock_contentful.find('alpha'))
    allow(Training::Module).to receive(:ordered).and_return([mock_contentful.find('alpha'), mock_contentful.find('bravo')])
  end

  subject(:decorator) do
    described_class.new(content, user)
  end

  it '#heading' do
    expect(decorator.heading).to eq 'Additional feedback'
  end

  it '#section_numbers' do
    expect(decorator.section_numbers).to eq 'Section 4 of 4'
  end

  it '#page_numbers' do
    expect(decorator.page_numbers).to eq 'Page 1 of 9'
  end

  it '#percentage' do
    expect(decorator.percentage).to eq '11%'
  end

  context 'when one-off questions have already been answered' do
    before do
      create :response,
             question_name: 'feedback-skippable',
             training_module: 'bravo',
             answers: [1],
             correct: true,
             user: user,
             question_type: 'feedback'
    end

    it '#page_numbers' do
      expect(decorator.page_numbers).to eq 'Page 1 of 8'
    end
  end

  context 'when one-off questions are being answered' do
    let(:content) { mod.page_by_name('feedback-skippable') }

    before do
      create :response,
             question_name: 'feedback-skippable',
             training_module: 'alpha',
             answers: [1],
             correct: true,
             user: user,
             question_type: 'feedback'
    end

    it '#page_numbers' do
      expect(decorator.page_numbers).to eq 'Page 8 of 9'
    end
  end
end
