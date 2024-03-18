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

  describe '#module_version' do
    let(:mod) { Training::Module.by_name(:delta) }
  
    context 'with module versions predating the user\'s module start' do
      before do
        create :module_release, id: 4, name: mod.name, module_position: mod.position, versions: { '1' => 3.days.ago, '2' => 2.days.ago, '3' => 1.hour.ago }
        allow(changes).to receive(:module_started_at).and_return(1.day.ago)
      end
  
      it 'returns the latest version for that user' do
        expect(changes.module_version(mod)).to eq('2')
      end
    end
  end
end
