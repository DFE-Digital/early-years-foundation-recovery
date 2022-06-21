require 'rails_helper'

RSpec.describe ModuleOverviewDecorator do
  subject(:decorator) { described_class.new(user: user, mod: alpha) }

  # let(:alpha) { TrainingModule.find_by(name: :alpha) }

  # include_context 'with progress'

  # describe '#milestone' do
  #   it 'returns the name of the last viewed page' do
  #     view_module_page_event('alpha', '1-1')
  #     view_module_page_event('alpha', '1-2-4')
  #     expect(progress.milestone).to eq '1-2-4'

  #     view_module_page_event('alpha', '1-1-3')
  #     expect(progress.milestone).to eq '1-1-3'
  #   end
  # end
end
