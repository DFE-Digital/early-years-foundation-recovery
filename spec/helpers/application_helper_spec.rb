require 'rails_helper'

describe 'ApplicationHelper', type: :helper do
  it '#html_title' do
    expect(helper.html_title(:foo, 'bar')).to eq 'Early years child development training : foo : bar'
  end

  it '#configuration_summary_list includes the compiled GOV.UK Frontend version' do
    frontend_version = JSON.parse(File.read(Rails.root.join('package.json'))).fetch('devDependencies').fetch('govuk-frontend')

    expect(helper.configuration_summary_list).to include('GOV.UK Frontend', frontend_version)
  end

  describe '#show_important_banner' do
    context 'when SHOW_IMPORTANT_BANNER is true' do
      before { allow(ENV).to receive(:[]).with('SHOW_IMPORTANT_BANNER').and_return('true') }

      it 'returns true' do
        expect(helper.show_important_banner?).to be true
      end

      describe '#track_analytics?' do
        it 'honours consent outside review apps' do
          cookies[:track_analytics_v2] = 'true'
          expect(helper.track_analytics?).to be true
        end

        it 'requires consent outside review apps' do
          expect(helper.track_analytics?).to be false
        end

        it 'never sends review activity to analytics even with consent' do
          cookies[:track_analytics_v2] = 'true'
          allow(Rails.application.config).to receive(:review_app).and_return(true)

          expect(helper.track_analytics?).to be false
        end
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
