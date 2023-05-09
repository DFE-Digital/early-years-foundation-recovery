require 'rails_helper'
require 'reporting'

RSpec.describe Reporting do
  let(:user1) do
    create(:user, :registered, email: 'test1@example.com')
  end

  let(:user2) do
    create(:user, :registered, email: 'test2@example.com')
  end

  let(:user1_note1) do
    user1.notes.create(body: 'test note body')
  end

  let(:user1_note2) do
    user1.notes.create(body: 'test note body 2')
  end

  let(:user2_note) do
    user2.notes.create(body: 'test note body')
  end

  describe '.get_users_with_notes_count' do
    subject(:notes_count) do
      described_class.get_users_with_notes_count
    end

    context 'when 0 users or notes exist' do
      it 'returns 0 when no notes or users exist' do
        expect(notes_count).to eq(0)
      end
    end

    context 'when a user has a note' do
      it 'returns 1' do
        expect(user1_note1.body).to eq('test note body')
        expect(user1.notes.count).to eq(1)
        expect(notes_count).to eq(1)
      end
    end

    context 'when there is 1 user with multiple notes' do
      it 'returns 1' do
        expect(user1_note1.body).to eq('test note body')
        expect(user1_note2.body).to eq('test note body 2')
        expect(user1.notes.count).to eq(2)
        expect(notes_count).to eq(1)
      end
    end

    context 'when 1 user has notes and 1 has none' do
      it 'returns 1' do
        expect(user1_note1.body).to eq('test note body')
        expect(user2.email).to eq('test2@example.com')
        expect(user1.notes.count).to eq(1)
        expect(user2.notes.count).to eq(0)
        expect(notes_count).to eq(1)
      end
    end

    context 'when 2 users have notes' do
      it 'returns 2' do
        expect(user1_note1.body).to eq('test note body')
        expect(user2_note.body).to eq('test note body')
        expect(user1.notes.count).to eq(1)
        expect(user2.notes.count).to eq(1)
        expect(notes_count).to eq(2)
      end
    end
  end
end
