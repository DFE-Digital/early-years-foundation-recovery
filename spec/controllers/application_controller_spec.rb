require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe '#guest' do
    subject(:guest) { controller.send(:guest) }

    context 'with a bot' do
      it 'instantiates a new visit' do
        expect(guest.visit.id).to be_nil
        expect(guest).to be_a Guest
      end
    end

    context 'with a browser' do
      let(:current_visit) { create(:visit) }

      it 'uses the current visit' do
        allow(controller).to receive(:current_visit).and_return(current_visit)
        expect(guest.visit.id).to eq current_visit.id
        expect(guest).to be_a Guest
      end
    end

    context 'with a cookie' do
      let(:cookie_token) { 'some-token' }

      before do
        create(:visit, visit_token: cookie_token)
        request.cookies[:course_feedback] = cookie_token
      end

      it 'fetches a previous visit' do
        expect(guest).to be_a Guest
        expect(guest.visit_token).to eq cookie_token
      end
    end
  end

  describe '#set_time_zone' do
    controller do
      def index
        render plain: 'Time zone set'
      end
    end

    before do
      allow(Time).to receive(:use_zone).and_yield
    end

    context 'when ENV["TZ"] is set to a valid time zone' do
      before { allow(ENV).to receive(:[]).with('TZ').and_return('America/New_York') }

      it 'sets the time zone correctly' do
        expect(Time).to receive(:use_zone).with('America/New_York')
        get :index
      end
    end

    context 'when ENV["TZ"] is set to an invalid time zone' do
      before { allow(ENV).to receive(:[]).with('TZ').and_return('Invalid/Timezone') }

      it 'falls back to UTC' do
        expect(Time).to receive(:use_zone).with('UTC')
        get :index
      end
    end

    context 'when ENV["TZ"] is not set' do
      before { allow(ENV).to receive(:[]).with('TZ').and_return(nil) }

      it 'falls back to UTC' do
        expect(Time).to receive(:use_zone).with('UTC')
        get :index
      end
    end
  end
end
