require 'rails_helper'

describe 'ApplicationHelper', type: :helper do
  it '#html_title' do
    expect(helper.html_title(:foo, 'bar')).to eq 'Early years child development training : foo : bar'
  end

  describe '#show_important_banner' do
    context 'when SHOW_IMPORTANT_BANNER is true' do
      before { allow(ENV).to receive(:[]).with('SHOW_IMPORTANT_BANNER').and_return('true') }

      it 'returns true' do
        expect(helper.show_important_banner?).to be true
      end
    end

    context 'when SHOW_IMPORTANT_BANNER is false' do
      before { allow(ENV).to receive(:[]).with('SHOW_IMPORTANT_BANNER').and_return('false') }

      it 'returns false' do
        expect(helper.show_important_banner?).to be false
      end
    end
  end
end
