require 'rails_helper'

RSpec.describe CourseProgress do
  subject(:course) { described_class.new(user: user) }

  include_context 'with progress'

  describe '#course_completed?' do
    it 'is false for new users' do
      expect(course.course_completed?).to be false
    end

    it 'is true once all published module pages are viewed' do
      published_mods.each { |mod| complete_module(mod) }

      course = described_class.new(user: user)
      expect(course.course_completed?).to be true
    end
  end

  describe '#current_modules' do
    it 'returns a list of modules in progress' do
      expect(course.current_modules).to be_empty

      start_module(alpha)
      course = described_class.new(user: user)
      expect(course.current_modules.map(&:name)).to eq %w[alpha]

      start_module(bravo)
      course = described_class.new(user: user)
      expect(course.current_modules.map(&:name)).to eq %w[alpha bravo]

      complete_module(alpha)
      course = described_class.new(user: user)
      expect(course.current_modules.map(&:name)).to eq %w[bravo]
    end
  end

  describe '#available_modules' do
    it 'returns a list of modules that can be started' do
      expect(course.available_modules.map(&:name)).to eq %w[alpha bravo charlie]

      start_module(alpha)
      course = described_class.new(user: user)
      expect(course.available_modules.map(&:name)).to eq %w[bravo charlie]

      complete_module(alpha)
      course = described_class.new(user: user)
      expect(course.available_modules.map(&:name)).to eq %w[bravo charlie]

      start_module(bravo)
      course = described_class.new(user: user)
      expect(course.available_modules.map(&:name)).to eq %w[charlie]

      complete_module(bravo)
      course = described_class.new(user: user)
      expect(course.available_modules.map(&:name)).to eq %w[charlie]
    end
  end

  describe '#upcoming_modules' do
    it 'includes draft modules' do
      expect(course.upcoming_modules.map(&:name)).to include('delta')
      expect(course.upcoming_modules.count).to eq 1
    end

    it 'does not contain available modules' do
      available = course.available_modules.map(&:name)
      upcoming  = course.upcoming_modules.map(&:name)

      expect(upcoming & available).to be_empty
    end
  end

  describe '#completed_modules' do
    it 'returns the completion date' do
      travel_to Time.zone.parse('2022-06-30 00:30:00 UTC') do
        complete_module(bravo)
        course = described_class.new(user: user)

        expect(course.completed_modules.count).to eq 1

        mod, completion_time = course.completed_modules.first
        expect(mod.name).to eq 'bravo'
        expect(completion_time).to be_an ActiveSupport::TimeWithZone
        expect(completion_time.to_s).to eq '2022-06-30 00:30:00 UTC'
      end
    end
  end

  describe '#completed_all_modules?' do
    it 'is false when no modules completed' do
      expect(course.completed_all_modules?).to be false
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
