require 'rails_helper'

RSpec.describe ContentChanges do
  subject(:changes) { described_class.new(user: user) }

  let(:user) { create(:user) }

  include_context 'with module releases'

  describe '#new_modules?' do
    context 'without previous visits' do
      specify { expect(changes.new_modules?).to be false }
    end

    context 'with visits predating a modules release' do
      before do
        create :visit,
               id: 1,
               visitor_token: '123',
               user_id: user.id,
               started_at: 1.day.ago
      end

      specify { expect(changes.new_modules?).to be true }
    end
  end

  describe '#new_module?' do
    let(:param) { Training::Module.by_name(:alpha) }
    let(:result) { changes.new_module?(param) }

    context 'without previous visits' do
      specify { expect(result).to be false }
    end

    context 'with visits since the modules release' do
      before do
        create :visit,
               id: 1,
               visitor_token: '123',
               user_id: user.id,
               started_at: 1.minute.ago
      end

      specify { expect(result).to be false }
    end

    context 'with visits predating a modules release' do
      before do
        create :visit,
               id: 1,
               visitor_token: '123',
               user_id: user.id,
               started_at: 5.days.ago
      end

      specify { expect(result).to be true }

      context 'and a module in progress' do
        include_context 'with progress'
        before do
          start_module(alpha)
        end

        specify { expect(result).to be false }
      end
    end
  end
end
