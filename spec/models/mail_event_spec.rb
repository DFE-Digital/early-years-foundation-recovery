require 'rails_helper'

RSpec.describe MailEvent, type: :model do
  describe '.for_module_release_email' do
    let(:user) { create :user, :registered }
    let(:contentful_entry_id) { 'module-alpha-id' }

    it 'returns only release emails for the requested Contentful ID' do
      create :mail_event,
             user: user,
             template: 'wrong-template',
             personalisation: { contentful_entry_id: contentful_entry_id }

      create :mail_event,
             user: user,
             template: NewModuleMailJob.template_id,
             personalisation: { contentful_entry_id: 'module-bravo-id' }

      matching_event = create :mail_event,
                              user: user,
                              template: NewModuleMailJob.template_id,
                              personalisation: { contentful_entry_id: contentful_entry_id }

      expect(
        described_class.for_module_release_email(contentful_entry_id),
      ).to contain_exactly(matching_event)
    end
  end
end
