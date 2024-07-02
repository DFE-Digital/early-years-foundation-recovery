require 'rails_helper'

describe Course, type: :model do
  subject(:course) { described_class.config }

  describe '.config' do
    it 'service_name' do
      expect(course.service_name).to eq 'Early years child development training'
    end

    it 'privacy_policy_url' do
      expect(course.privacy_policy_url).to eq 'https://www.gov.uk/government/publications/privacy-information-members-of-the-public/privacy-information-members-of-the-public'
    end

    it 'internal_mailbox' do
      expect(course.internal_mailbox).to eq 'child-development.training@education.gov.uk'
    end

    it 'pages' do
      expect(course.pages.count).to eq 9
      expect(course.pages.first.page_type).to eq 'feedback'
      expect(course.pages.last.page_type).to eq 'text_page'
    end

    it 'feedback_questions' do
      expect(course.feedback_questions.count).to eq 8
    end
  end

  # PoC to ensure exisiting parent#pages logic is reusable
  #
  describe 'site-wide feedback form navigation/pagination' do
    let(:parent) { described_class.config }
    let(:pages) { described_class.config.pages }

    it 'parent has pages' do
      expect(parent.pages.first).to be_a Training::Question
      expect(pages.first.parent.pages.last).to be_a Training::Page
    end

    it 'pages have a parent' do
      expect(pages.first.parent).to be_a described_class
      expect(pages.first.parent).to eq pages.last.parent
    end

    it 'page order uing previous_item/next_item' do
      expect(pages.first.name).to eq 'feedback-radio-only'
      expect(pages.first.next_item.name).to eq 'feedback-checkbox-only'
      expect(pages.first.next_item.next_item.name).to eq 'feedback-textarea-only'
      expect(pages.first.next_item.previous_item.name).to eq 'feedback-radio-only'
    end
  end
end
