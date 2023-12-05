require 'rails_helper'

RSpec.describe ContentChanges do
  subject(:changes) { described_class.new(user: user) }

  let(:user) { create(:user) }

  include_context 'with module releases'

  describe '#new_modules?' do
    context 'without previous visits' do
      it 'returns false' do
        expect(changes.new_modules?).to be false
      end
    end

    context 'with visits predating a modules release' do
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

      it 'returns true' do
        expect(changes.new_modules?).to be true
      end
    end
  end

  describe '#new_module?' do
    let(:alpha) { Training::Module.by_name(:alpha) }

    context 'without previous visits' do
      it 'returns false' do
        expect(changes.new_module?(alpha)).to be false
      end
    end

    context 'with visits since the modules release' do
      before do
        create :visit,
               id: 1,
               visitor_token: '123',
               user_id: user.id,
               started_at: 1.minute.ago
      end

      it 'returns false' do
        expect(changes.new_module?(alpha)).to be false
      end
    end

    context 'with visits predating a modules release' do
      before do
        create :visit,
               id: 1,
               visitor_token: '123',
               user_id: user.id,
               started_at: 5.days.ago

        create :visit,
               id: 2,
               visitor_token: '456',
               user_id: user.id,
               started_at: 5.days.ago
      end

      it 'returns true' do
        expect(changes.new_module?(alpha)).to be true
      end

      context 'with a module in progress' do
        include_context 'with progress'
        before do
          create :visit,
                 id: 3,
                 visitor_token: '321',
                 user_id: user.id,
                 started_at: 5.days.ago

          create :visit,
                 id: 4,
                 visitor_token: '654',
                 user_id: user.id,
                 started_at: 5.days.ago
          start_module(alpha)
        end

        it 'returns false' do
          expect(changes.new_module?(alpha)).to be false
        end
      end
    end
  end
end
