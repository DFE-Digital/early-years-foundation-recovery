require 'rails_helper'

RSpec.describe CourseProgress do
  subject(:course) { described_class.new(user: user) }

  include_context 'with progress'

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

    it do
      expect(course.completed_all_modules?).to eq false
    end
  end

  describe '#debug_summary' do
    it 'summarises information' do
      expect(course.debug_summary).to eq(
        <<~SUMMARY,
          ---
          title: First Training Module
          published at: Management Key Missing
          position: 1
          name: alpha
          draft: false
          started: false
          completed: false
          last: 1-3-3-5
          certificate: 1-3-4
          milestone: N/A
          ---
          title: Second Training Module
          published at: Management Key Missing
          position: 2
          name: bravo
          draft: false
          started: false
          completed: false
          last: 1-3-3-5-bravo
          certificate: 1-3-4
          milestone: N/A
          ---
          title: Third Training Module
          published at: Management Key Missing
          position: 3
          name: charlie
          draft: false
          started: false
          completed: false
          last: 1-3-3-5
          certificate: 1-3-4
          milestone: N/A
          ---
          title: Fourth Training Module
          published at: Management Key Missing
          position: 4
          name: delta
          draft: true
          started: false
          completed: false
          last: N/A
          certificate: N/A
          milestone: N/A
        SUMMARY
      )
    end
  end
end
