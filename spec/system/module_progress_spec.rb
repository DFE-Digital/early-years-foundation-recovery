require 'rails_helper'

RSpec.describe 'Module progress' do
  include_context 'with user'
  include_context 'with progress'

  let(:alpha) { TrainingModule.find_by(name: :alpha) }
  let(:charlie) { TrainingModule.find_by(name: :charlie) }

  describe '#completed_at' do
    it 'returns module complete date when there is an assessment in the module' do
      pending 'make complete module work for assessments'
      travel_to Time.zone.parse('2025-01-01') do
        alpha_progress = ModuleProgress.new(user: user, mod: alpha)
        complete_module(alpha)
        expect(alpha_progress.completed_at.to_s).to eq('2025-01-01 00:00:00 UTC')
      end
    end

    it 'returns last page viewed when there is no assessment' do
      travel_to Time.zone.parse('2022-09-26') do
        charlie_progress = ModuleProgress.new(user: user, mod: charlie)
        complete_module(charlie)
        expect(charlie_progress.completed_at.to_s).to eq('2022-09-26 00:00:00 UTC')
      end
    end
  end
end
