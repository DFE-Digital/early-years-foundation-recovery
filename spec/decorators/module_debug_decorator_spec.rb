require 'rails_helper'

RSpec.describe ModuleDebugDecorator do
  subject(:decorator) { described_class.new(progress) }

  let(:progress) { ModuleProgress.new(user: user, mod: bravo, user_module_events: []) }
  let(:bravo) { Training::Module.by_name('bravo') }
  let(:user) { create(:user, :registered) }

  describe '#rows' do
    let(:output) { decorator.rows }

    it 'headers' do
      expect(output.first).to eq %w[
        Position
        Visited
        Sections
        Progress
        Submodule
        Topic
        Pages
        Model
        Type
        Name
      ]
    end

    it 'rows' do
      expect(output.second).to eq [
        '1st',
        'false',
        'Section 1 of 4',
        '25%',
        '1',
        '0',
        'Page 1 of 4',
        'page',
        'sub_module_intro',
        '<a href="/modules/bravo/content-pages/1-1">1-1</a>',
      ]

      expect(output.third).to eq [
        '2nd',
        'false',
        'Section 1 of 4',
        '50%',
        '1',
        '1',
        'Page 2 of 4',
        'page',
        'topic_intro',
        '<a href="/modules/bravo/content-pages/1-1-1">1-1-1</a>',
      ]
    end
  end
end
