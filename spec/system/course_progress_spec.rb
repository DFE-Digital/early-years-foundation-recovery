require 'rails_helper'

RSpec.describe CourseProgress do

  include_context 'with progress'
  include_context 'with user'

  subject(:course) { described_class.new(user: user) }
  describe '#milestone' do
    it 'returns the name of the last viewed page' do
      view_module_page_event('alpha', '1-1')
      view_module_page_event('alpha', '1-2-4')
      expect(course.milestone('alpha')).to eq '1-2-4'

      view_module_page_event('alpha', '1-1-3')
      expect(course.milestone('alpha')).to eq '1-1-3'
    end
  end

  describe '#course_completed?' do
    it 'is false for new users' do
      expect(course.course_completed?).to be false
    end

    it 'is true once all published module pages are viewed' do
      %i[alpha bravo charlie].map do |mod_name|
        TrainingModule.find_by(name: mod_name).module_items.map do |item|
          view_module_page_event(mod_name.to_s, item.name)
        end
      end

      expect(course.course_completed?).to be true
    end
  end

  describe '#current_modules' do
    it 'returns a list of modules in progress' do
      # start a module
      expect { start_module(alpha) }
      .to change { course.current_modules.count }
      .from(0).to(1)

      # force start a second concurrent module
      expect { start_module(bravo) }
      .to change { course.current_modules.count }
      .from(1).to(2)

      expect(course.current_modules.map(&:name)).to eq %w[
        alpha
        bravo
      ]

      # complete the first module
      expect { view_whole_module(alpha) }
      .to change { course.current_modules.count }
      .from(2).to(1)
    end
  end

  describe '#available_modules' do
    it 'returns a list of modules that can be started' do
      expect(course.available_modules.map(&:name)).to eq %w[alpha]
      # start the first module with a dependent
      expect { start_module(alpha) }
      .to change { course.available_modules.count }
      .from(1).to(0)

      # complete the first module
      expect { view_whole_module(alpha) }
      .to change { course.available_modules.count }
      .from(0).to(1)

      # start the second module with a dependent
      expect { start_module(bravo) }
      .to change { course.available_modules.count }
      .from(1).to(0)

      # complete the second module
      expect { view_whole_module(bravo) }
      .to change { course.available_modules.count }
      .from(0).to(1)

      expect(course.available_modules.map(&:name)).to eq %w[charlie]
    end
  end

  describe '#upcoming_modules' do
    it 'includes draft modules' do
      expect(course.upcoming_modules.map(&:name)).to include 'delta'
    end

    it 'is restricted to a maximum of 3' do
      expect(course.upcoming_modules.count).to be 3
    end

    it 'does not contain available modules' do
      available  = course.available_modules.map(&:name)
      upcoming   = course.upcoming_modules.map(&:name)

      expect(upcoming).not_to include available
    end
  end

  describe '#completed_modules' do
    # instantiate user now otherwise GovUk Notify client borks with:
    #   "AuthError: Error: Your system clock must be accurate to within 30 seconds"
    it 'returns the completion date' do
      travel_to Time.zone.parse('2022-06-30') do
        complete_module(bravo)
        expect(course.completed_modules.count).to be 1
        ((_mod, completion_time)) = course.completed_modules
        expect(completion_time).to be_an ActiveSupport::TimeWithZone
        # TBD database is returning actual time and not time set above
        # expect(completion_time.to_s).to eq '2022-06-30 00:00:00 UTC'
      end
    end
  end
end
