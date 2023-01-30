require 'rails_helper'

RSpec.describe ContentfulModuleProgress, :cms do
  subject(:service) { described_class.new(user: user, mod: alpha) }

  include_context 'with progress'

  let(:alpha) { Training::Module.by_name(:alpha) }

  # describe '#started?' do
  # end

  # describe '#completed?' do
  # end

  describe '#milestone' do
    it 'returns the name of the last viewed page' do
      view_module_page_event('alpha', '1-1')
      view_module_page_event('alpha', '1-2-4')
      expect(service.milestone).to eq '1-2-4'

      view_module_page_event('alpha', '1-1-3')
      expect(service.milestone).to eq '1-1-3'
    end
  end

  describe '#resume_page' do
    it 'returns the furthest reached content' do
      %w[
        what-to-expect
        before-you-start
        intro
        1-1
        1-1-1
        1-1-2
        1-1-3
        1-1-3-1
      ].map do |page|
        view_module_page_event('alpha', page)
      end

      expect(service.resume_page.name).to eq '1-1-3-1'

      view_module_page_event('alpha', '1-1')
      expect(service.resume_page.name).to eq '1-1-3-1'
    end
  end
end
