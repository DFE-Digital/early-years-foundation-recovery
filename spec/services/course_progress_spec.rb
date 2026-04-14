require 'rails_helper'
require 'support/shared/with_progress'

RSpec.describe CourseProgress do
  subject(:course) { described_class.new(user: user) }

  include_context 'with progress'

  unless ENV['CONTENTFUL_PREVIEW'] == 'true'
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
  end

  describe '#available_modules' do
    it 'returns a list of modules that can be started' do
      # Initially, all published modules should be available
      expect(course.available_modules.map(&:name)).to eq %w[alpha bravo charlie]

      # Start the first module, it should no longer be available
      start_module(alpha)
      course = described_class.new(user: user)
      expect(course.available_modules.map(&:name)).to eq %w[bravo charlie]

      # Complete the second module, it should also be removed from available
      start_module(bravo)
      complete_module(bravo)
      course = described_class.new(user: user)
      expect(course.available_modules.map(&:name)).to eq %w[charlie]

      # Complete all modules, none should be available
      start_module(charlie)
      complete_module(charlie)
      course = described_class.new(user: user)
      expect(course.available_modules.map(&:name)).to eq []
    end
  end

  unless ENV['CONTENTFUL_PREVIEW'] == 'true'
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

  describe '#completed_all_modules?' do
    it 'is false when no modules completed' do
      expect(course.completed_all_modules?).to be false
    end
  end

  unless ENV['CONTENTFUL_PREVIEW'] == 'true'
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
end
