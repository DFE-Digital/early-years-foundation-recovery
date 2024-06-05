require 'rails_helper'

RSpec.describe MailEvent, type: :model do
  describe '.newest_module' do
    let(:user) { create :user, :registered }

    it 'latest module messages' do
      create :mail_event, user: user, template: 'wrong'
      create :mail_event, user: user, template: '2352b6ce-a098-47f0-870a-286308b9798f', personalisation: { mod_number: 1 }
      expect(described_class.newest_module.count).to eq 0

      create :mail_event, user: user, template: '2352b6ce-a098-47f0-870a-286308b9798f', personalisation: { mod_number: 3 }
      expect(described_class.newest_module.count).to eq 1
    end
  end
end
