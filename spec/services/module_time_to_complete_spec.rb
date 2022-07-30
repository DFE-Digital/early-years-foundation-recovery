require 'rails_helper'

RSpec.describe ModuleTimeToComplete do
  subject(:completion_time) { described_class.new(user: user, training_module_id: 'alpha') }

  let(:user) { create(:user, :confirmed) }

  include_context 'with progress'

  before do
    # instantiate user now otherwise GovUk Notify client borks with:
    # "AuthError: Error: Your system clock must be accurate to within 30 seconds"
    user

    # create a fake event log item for 'module_start' event key
    travel_to Time.zone.parse('2022-06-30 00:00:00') do
      view_module_page_event_with_specified_key('alpha', 'intro', 'module_start', 'content_pages')
    end

    # create a fake event log item for 'module_complete' event key
    travel_to Time.zone.parse('2022-06-30 00:10:20') do
      view_module_page_event_with_specified_key('alpha', 'certificate', 'module_complete', 'training_modules')
    end
  end

  describe '#update_time' do
    it 'returns a hash containing the users module time to completion for a module' do
      result = completion_time.update_time
      expect(result).to include('alpha' => 620)
    end
  end
end
