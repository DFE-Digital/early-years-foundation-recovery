require 'rails_helper'

RSpec.describe ModuleDebugDecorator do
  subject(:decorator) { described_class.new(progress) }

  let(:progress) { ModuleProgress.new(user: user, mod: bravo) }
  let(:bravo) { Training::Module.by_name('bravo') }
  let(:user) { create(:user, :registered) }

  describe '#rows' do
    let(:output) { decorator.rows }

    xit do
      expect(output).to eq [
        [],
      ]
    end
  end
end
