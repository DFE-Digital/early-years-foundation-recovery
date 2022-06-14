require 'rails_helper'

RSpec.describe UserTraining do
  subject(:learning) { described_class.new(user: user) }

  let(:user) { create(:user) }
  let(:tracker) { Ahoy::Tracker.new(user: user, controller: 'content_pages') }

  # @return [true] create a fake event log item
  def view_module_page_event(module_name, page_name)
    tracker.track("Viewing #{page_name}", {
      id: page_name,
      action: 'show',
      controller: 'content_pages',
      training_module_id: module_name,
    })
  end

  describe '#milestone' do
    it 'returns the name of the last viewed page' do
      view_module_page_event('alpha', '1-1')
      view_module_page_event('alpha', '1-2-4')
      expect(learning.milestone('alpha')).to eq '1-2-4'

      view_module_page_event('alpha', '1-1-3')
      expect(learning.milestone('alpha')).to eq '1-1-3'
    end
  end

  describe '#course_completed?' do
    it 'is false for new users' do
      expect(learning.course_completed?).to be false
    end

    # create viewing event for last page
    it 'is true once all published modules are completed' do
      view_module_page_event('alpha', '1-2-4')
      view_module_page_event('bravo', '1-2-2-1')
      view_module_page_event('charlie', '1-1-3')

      expect(learning.course_completed?).to be true
    end
  end

  describe '#current_modules' do
    it 'returns a list of modules in progress' do
      # start a module
      expect { view_module_page_event('alpha', '1-1') }
      .to change { learning.current_modules.count }
      .from(0).to(1)

      # force start a second concurrent module
      expect { view_module_page_event('bravo', '1-1') }
      .to change { learning.current_modules.count }
      .from(1).to(2)

      expect(learning.current_modules.map(&:name)).to eq %w[
        alpha
        bravo
      ]

      # complete the first module
      expect { view_module_page_event('alpha', '1-2-4') }
      .to change { learning.current_modules.count }
      .from(2).to(1)
    end
  end

  describe '#available_modules' do
    it 'returns a list of modules that can be started' do
      expect(learning.available_modules.map(&:name)).to eq %w[
        alpha
      ]

      # start the first module with a dependent
      expect { view_module_page_event('alpha', '1-1') }
      .to change { learning.available_modules.count }
      .from(1).to(0)

      # complete the first module
      expect { view_module_page_event('alpha', '1-2-4') }
      .to change { learning.available_modules.count }
      .from(0).to(1)

      # start the second module with a dependent
      expect { view_module_page_event('bravo', '1-1') }
      .to change { learning.available_modules.count }
      .from(1).to(0)

      # complete the second module
      expect { view_module_page_event('bravo', '1-2-2-1') }
      .to change { learning.available_modules.count }
      .from(0).to(1)

      expect(learning.available_modules.map(&:name)).to eq %w[
        charlie
      ]
    end
  end

  describe '#upcoming_modules' do
    it 'includes draft modules' do
      expect(learning.upcoming_modules.map(&:name)).to include 'delta'
    end

    it 'is restricted to a maximum of 3' do
      expect(learning.upcoming_modules.count).to be 3
    end

    it 'does not contain available modules' do
      available  = learning.available_modules.map(&:name)
      upcoming   = learning.upcoming_modules.map(&:name)

      expect(upcoming).not_to include available
    end
  end

  describe '#completed_modules' do
    # instantiate user now otherwise GovUk Notify client borks with:
    #   "AuthError: Error: Your system clock must be accurate to within 30 seconds"
    before { user }

    it 'returns the completion date' do
      travel_to Time.zone.parse('2022-06-30') do
        view_module_page_event('bravo', '1-2-2-1')
        expect(learning.completed_modules.count).to be 1
        completion_time = learning.completed_modules.first[1]
        expect(completion_time).to be_an ActiveSupport::TimeWithZone
        expect(completion_time.to_s).to eq '2022-06-30 00:00:00 UTC'
      end
    end
  end
end
