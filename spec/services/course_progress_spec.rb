require 'rails_helper'

RSpec.describe CourseProgress do
  subject(:course) { described_class.new(user: user) }

  include_context 'with progress'

  before do
    create(:release, id: 1)
    create(:module_release, release_id: 1, module_position: 1, name: 'alpha', first_published_at: 2.days.ago)
    create(:release, id: 2)
    create(:module_release, release_id: 2, module_position: 2, name: 'bravo', first_published_at: 3.days.ago)
    create(:release, id: 3)
    create(:module_release, release_id: 3, module_position: 3, name: 'charlie', first_published_at: 2.minutes.ago)
  end

  describe '#course_completed?' do
    it 'is false for new users' do
      expect(course.course_completed?).to be false
    end

    it 'is true once all published module pages are viewed' do
      published_mods.map { |mod| complete_module(mod) }

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
      expect { complete_module(alpha) }
      .to change { course.current_modules.count }
      .from(2).to(1)
    end
  end

  describe '#available_modules' do
    it 'returns a list of modules that can be started' do
      expect(course.available_modules.map(&:name)).to eq %w[alpha bravo charlie]
      # start the first module
      expect { start_module(alpha) }
      .to change { course.available_modules.count }
      .from(3).to(2)

      # complete the first module
      expect { complete_module(alpha) }.not_to(change { course.available_modules.count })

      # start the second module
      expect { start_module(bravo) }
      .to change { course.available_modules.count }
      .from(2).to(1)

      # complete the second module
      expect { complete_module(bravo) }.not_to(change { course.available_modules.count })

      expect(course.available_modules.map(&:name)).to eq %w[charlie]
    end
  end

  describe '#upcoming_modules' do
    it 'includes draft modules' do
      expect(course.upcoming_modules.map(&:name)).to include 'delta'
      expect(course.upcoming_modules.count).to be 1
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
        complete_module(bravo, 30.minutes)
        expect(course.completed_modules.count).to be 1

        ((_mod, completion_time)) = course.completed_modules

        expect(completion_time).to be_an ActiveSupport::TimeWithZone
        expect(completion_time.to_s).to eq '2022-06-30 00:30:00 UTC'
      end
    end
  end

  describe '#new_modules' do
    context 'with a new user' do
      it 'returns no modules' do
        expect(course.new_modules).to be_empty
      end
    end

    context 'with a user who has visited before' do
      before do
        create :visit,
               id: 1,
               visitor_token: '123',
               user_id: user.id,
               started_at: 1.day.ago

        create :visit,
               id: 2,
               visitor_token: '456',
               user_id: user.id,
               started_at: 1.minute.ago
      end

      it 'returns modules released since the user\'s last visit' do
        expect(course.new_modules.map(&:name)).to eq %w[charlie]
      end
    end
  end
end
