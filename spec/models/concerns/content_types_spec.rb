require 'rails_helper'

RSpec.describe ContentTypes, type: :model do
  subject(:klass) do
    Class.new do
      include ContentTypes
      attr_accessor :page_type
    end
  end

  let(:content) { klass.new }

  describe '#interruption_page?' do
    before { content.page_type = 'interruption_page' }

    specify { expect(content).to be_interruption_page }
  end

  describe '#submodule_intro?' do
    before { content.page_type = 'sub_module_intro' }

    specify { expect(content).to be_submodule_intro }
  end

  describe '#topic_intro?' do
    before { content.page_type = 'topic_intro' }

    specify { expect(content).to be_topic_intro }
  end

  describe '#text_page?' do
    before { content.page_type = 'text_page' }

    specify { expect(content).to be_text_page }
  end

  describe '#video_page?' do
    before { content.page_type = 'video_page' }

    specify { expect(content).to be_video_page }
  end

  describe '#formative_question?' do
    before { content.page_type = 'formative' }

    specify { expect(content).to be_formative_question }
  end

  describe '#summary_intro?' do
    before { content.page_type = 'summary_intro' }

    specify { expect(content).to be_summary_intro }
  end

  describe '#recap_page?' do
    before { content.page_type = 'recap_page' }

    specify { expect(content).to be_recap_page }
  end

  describe '#assessment_intro?' do
    before { content.page_type = 'assessment_intro' }

    specify { expect(content).to be_assessment_intro }
  end

  describe '#summative_question?' do
    before { content.page_type = 'summative' }

    specify { expect(content).to be_summative_question }
  end

  describe '#assessment_results?' do
    before { content.page_type = 'assessment_results' }

    specify { expect(content).to be_assessment_results }
  end

  describe '#confidence_intro?' do
    before { content.page_type = 'confidence_intro' }

    specify { expect(content).to be_confidence_intro }
  end

  describe '#confidence_question?' do
    before { content.page_type = 'confidence' }

    specify { expect(content).to be_confidence_question }
  end

  describe '#feedback_question?' do
    before { content.page_type = 'feedback' }

    specify { expect(content).to be_feedback_question }
  end

  describe '#thankyou?' do
    before { content.page_type = 'thankyou' }

    specify { expect(content).to be_thankyou }
  end

  describe '#certificate?' do
    before { content.page_type = 'certificate' }

    specify { expect(content).to be_certificate }
  end

  describe '#page_type' do
    let(:mod) { Training::Module.by_name(:alpha) }

    let(:types) { mod.pages.map(&:page_type).uniq }

    specify do
      expect(types).to eq(%w[
        interruption_page
        sub_module_intro
        topic_intro
        text_page
        formative
        video_page
        summary_intro
        recap_page
        assessment_intro
        summative
        assessment_results
        confidence_intro
        confidence
        feedback
        thankyou
        certificate
      ])
    end
  end
end
