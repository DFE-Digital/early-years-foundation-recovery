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
      expect(course.feedback).to be_empty
      # - only one question type
      # - number of questions
    end
  end
end
