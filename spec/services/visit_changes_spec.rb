require 'rails_helper'

RSpec.describe VisitChanges do
  subject(:changes) { described_class.new(user: user) }

  include_context 'with progress'

  before do
    create(:release, id: 1)
    create(:module_release, release_id: 1, module_position: 1, name: 'alpha', first_published_at: 2.days.ago)
    create(:release, id: 2)
    create(:module_release, release_id: 2, module_position: 2, name: 'bravo', first_published_at: 3.days.ago)
    create(:release, id: 3)
    create(:module_release, release_id: 3, module_position: 3, name: 'charlie', first_published_at: 2.minutes.ago)
  end

  describe '#new_modules' do
    context 'with a new user' do
      it 'returns no modules' do
        expect(changes.new_modules).to be_empty
      end
    end

    context 'with a user who has visited before' do
      before do
        create :visit,
               id: 1,
               visitor_token: '123',
               user_id: user.id,
               started_at: 1.day.ago

        create :visit,
               id: 2,
               visitor_token: '456',
               user_id: user.id,
               started_at: 1.minute.ago
      end

      it 'returns modules released since the user\'s last visit' do
        expect(changes.new_modules.map(&:name)).to eq %w[charlie]
      end
    end
  end
end
