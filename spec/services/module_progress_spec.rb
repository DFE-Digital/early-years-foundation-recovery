require 'rails_helper'

RSpec.describe ModuleProgress do
  subject(:progress) { described_class.new(user: user, mod: alpha) }

  let(:alpha) { TrainingModule.find_by(name: :alpha) }

  include_context 'with progress'

  # describe '#started?' do
  # end

  # describe '#completed?' do
  # end

  describe '#milestone' do
    it 'returns the name of the last viewed page' do
      view_module_page_event('alpha', '1-1')
      view_module_page_event('alpha', '1-2-4')
      expect(progress.milestone).to eq '1-2-4'

      view_module_page_event('alpha', '1-1-3')
      expect(progress.milestone).to eq '1-1-3'
    end
  end

  describe '#resume_page' do
    it 'returns the furthest visited module item' do
      %w[
        before-you-start
        what-to-expect
        intro
        1-1
        1-1-1
        1-1-2
        1-1-3
        1-1-3-1
      ].map do |page|
        view_module_page_event('alpha', page)
      end

      expect(progress.resume_page.name).to eq '1-1-3-1'

      view_module_page_event('alpha', '1-1')
      expect(progress.resume_page.name).to eq '1-1-3-1'
    end
  end
end
