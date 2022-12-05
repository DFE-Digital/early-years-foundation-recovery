require 'rails_helper'

RSpec.describe ModuleProgressBarDecorator do
  subject(:decorator) { described_class.new(progress) }

  let(:progress) { ModuleProgress.new(user: user, mod: alpha) }
  let(:alpha) { TrainingModule.find_by(name: :alpha) }

  include_context 'with progress'

  describe '#progress_bar_info' do
    let(:output) do
      decorator.progress_bar_info do
        {
          index: index,
          heading: heading,
          class: style,
          first: first,
          bold: bold,
          position: position,
          content_helper_values: content_helper_values,
        }
      end
    end

    context 'when on first intro page' do
      before do
        view_pages_before(alpha, 'interruption_page')
      end

      [
        {
          index: 0,
          heading: 'Module introduction',
          class: nil,
          first: true,
          bold: true,
          position: 'Step 1: ',
          content_helper_values: ['circle', :solid, :green, 'started'],
        },
        {
          index: 1,
          heading: 'The first submodule',
          class: 'line line--grey',
          first: false,
          bold: false,
          position: 'Step 2: ',
          content_helper_values: ['circle', :regular, :grey, 'not started'],
        },
        {
          index: 2,
          heading: 'The second submodule',
          class: 'line line--grey',
          first: false,
          bold: false,
          position: 'Step 3: ',
          content_helper_values: ['circle', :regular, :grey, 'not started'],
        },
        {
          index: 3,
          heading: 'Summary and next steps',
          class: 'line line--grey',
          first: false,
          bold: false,
          position: 'Step 4: ',
          content_helper_values: ['circle', :regular, :grey, 'not started'],
        },
      ].each_with_index do |item, index|
        describe '' do
          it { expect(item).to eq output[index] }
        end
      end
    end
  end
end
