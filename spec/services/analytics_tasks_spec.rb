require 'rails_helper'

RSpec.describe AnalyticsTasks do
  include_context 'with analytics tasks'

  describe '#users' do
    context 'run user analytics task'
    it 'returns nil' do
      expect(described_class.users).to match(nil)
    end
  end

  describe '#ahoy_events' do
    context 'run ahoy_events analytics task'
    it 'returns nil' do
      expect(described_class.ahoy_events).to match(nil)
    end
  end

  describe '#user_assessments' do
    context 'run user_assessments analytics task'
    it 'returns nil' do
      expect(described_class.user_assessments).to match(nil)
    end
  end

  describe '#user_answers' do
    context 'run user_answers analytics task'
    it 'returns nil' do
      expect(described_class.user_answers).to match(nil)
    end
  end

  describe '#ahoy_visits' do
    context 'run ahoy_visits analytics task'
    it 'returns nil' do
      expect(described_class.ahoy_visits).to match(nil)
    end
  end
end
