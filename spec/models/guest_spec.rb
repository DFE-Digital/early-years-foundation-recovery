require 'rails_helper'

RSpec.describe Guest, type: :model do
  subject(:guest) { described_class.new(visit: visit) }

  let(:visit) { create :visit }

  it 'needs a visit' do
    expect { described_class.new }.to raise_error Dry::Struct::Error
    expect { guest }.not_to raise_error
  end

  describe '#guest?' do
    specify do
      expect(guest).to be_guest
    end
  end

  describe '#response_for_shared' do
    before do
      create :response, question_name: content.name, training_module: 'course'
    end

    let(:content) { Course.config.pages.first }
    let(:response) { guest.response_for_shared(content) }

    specify do
      expect(response).to be_a Response
    end
  end

  describe '#course_started?' do
    specify do
      expect(guest).not_to be_course_started
    end
  end
end
