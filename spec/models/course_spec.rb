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

    it 'feedback' do
      expect(course.feedback).not_to be_empty
      expect(course.feedback.count).to be 5
      # expect(course.feedback.map(&:question_type)).to be 'feedback'
    end
  end

  # PoC to ensure exisiting parent#pages logic is reusable
  #
  describe 'site-wide feedback form navigation/pagination' do
    let(:parent) { described_class.config }
    let(:pages) { described_class.config.pages }

    it 'parent has pages' do
      expect(parent.pages.first).to be_a Training::Question
      expect(pages.first.parent.pages.last).to be_a Training::Question
    end

    it 'pages have a parent' do
      expect(pages.first.parent).to be_a described_class
      expect(pages.first.parent).to eq pages.last.parent
    end

    it 'page order uing previous_item/next_item' do
      expect(pages.first.name).to eq 'main-feedback-1'
      expect(pages.first.next_item.name).to eq 'main-feedback-2'
      expect(pages.first.next_item.next_item.name).to eq 'main-feedback-3'
      expect(pages.first.next_item.previous_item.name).to eq 'main-feedback-1'
    end
  end
end
