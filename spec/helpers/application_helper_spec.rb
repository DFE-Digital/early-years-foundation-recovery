require 'rails_helper'

describe 'ApplicationHelper', type: :helper do
  it '#html_title' do
    expect(helper.html_title(:foo, 'bar')).to eq 'Early years child development training : foo : bar'
  end

  describe '#show_pre_confidence_hint?' do
    context 'when SHOW_PRE_CONFIDENCE_HINT is true' do
      before { allow(ENV).to receive(:[]).with('SHOW_PRE_CONFIDENCE_HINT').and_return('true') }

      it 'returns true' do
        expect(helper.show_pre_confidence_hint?).to be true
      end
    end

    context 'when SHOW_PRE_CONFIDENCE_HINT is false' do
      before { allow(ENV).to receive(:[]).with('SHOW_PRE_CONFIDENCE_HINT').and_return('false') }

      it 'returns false' do
        expect(helper.show_pre_confidence_hint?).to be false
      end
    end

    context 'when SHOW_PRE_CONFIDENCE_HINT is not set' do
      before { allow(ENV).to receive(:[]).with('SHOW_PRE_CONFIDENCE_HINT').and_return(nil) }

      it 'returns false' do
        expect(helper.show_pre_confidence_hint?).to be false
      end
    end
  end
end
