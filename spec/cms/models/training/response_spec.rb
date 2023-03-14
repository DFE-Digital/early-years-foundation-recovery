require 'rails_helper'

RSpec.describe Response, :cms, type: :model do
  let(:user) { create :user, :registered }
  subject(:response) { user.responses.create( training_module: 'alpha', question_name: '1-1-4', answer: answer) }

  before do
    skip 'WIP' unless Rails.application.cms?
  end

  describe 'with no answer' do
    let(:answer) { nil }
    it 'is invalid' do
      expect(response).to be_invalid
      expect(response.errors.full_messages).to eq ["Answer can't be blank"]
    end
  end

  
  describe 'with correct answer' do
    let(:answer) { ['1'] }
    it 'banner title for successful assessment' do
      expect(response.banner_title).to eq("That's right")
    end
    
    it 'successful assessment summary' do
      expect(response.summary).to match(/You selected the correct answers/)
    end
  end

  describe 'with incorrect answer' do
    let(:answer) { ['2'] }
    it 'banner title for failing assessment' do
      expect(response.banner_title).to eq("That's not quite right")
    end
    
    it 'failure assessment summary' do
      expect(response.summary).to match(/You did not select the correct answers/)
    end
  end
end
