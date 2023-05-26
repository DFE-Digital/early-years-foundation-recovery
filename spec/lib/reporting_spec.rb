require 'rails_helper'
require 'reporting'

RSpec.describe Reporting do
  subject(:reporting) do
    Class.new { extend Reporting }
  end

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

  let(:blank_note) do
    user1.notes.create(body: '')
  end

  let(:nil_note) do
    user1.notes.create(body: nil)
  end

  let(:whitespace_note) do
    user1.notes.create(body: " \n \n \n")
  end

  describe '.users' do
    context 'when 0 users or notes exist' do
      it 'notes count is 0 and percentage is NaN' do
        expect(reporting.users[:with_notes]).to eq(0)
        expect(reporting.users[:with_notes_percentage].nan?).to eq(true)
      end
    end

    context 'when there are users but no notes' do
      it 'notes count is 0 and percentage is 0' do
        expect(user1.email).to eq('test1@example.com')
        expect(reporting.users[:with_notes]).to eq(0)
        expect(reporting.users[:with_notes_percentage]).to eq(0)
      end
    end

    context 'when there is a saved note but the body is empty' do
      it 'the note is not counted' do
        expect(user1.email).to eq('test1@example.com')
        expect(blank_note.body).to eq('')
        expect(whitespace_note.body).to eq(" \n \n \n")
        expect(reporting.users[:with_notes]).to eq(0)
        expect(reporting.users[:with_notes_percentage]).to eq(0)
      end
    end

    context 'when there is a saved note but the body is nil' do
      it 'the note is not counted' do
        expect(user1.email).to eq('test1@example.com')
        expect(nil_note.body).to eq(nil)
        expect(reporting.users[:with_notes]).to eq(0)
        expect(reporting.users[:with_notes_percentage]).to eq(0)
      end
    end

    context 'when a user has a note' do
      it 'notes count is 1 and percentage is 100' do
        expect(user1_note1.body).to eq('test note body')
        expect(user1.notes.count).to eq(1)
        expect(reporting.users[:with_notes]).to eq(1)
        expect(reporting.users[:with_notes_percentage]).to eq(100.0)
      end
    end

    context 'when there is 1 user with multiple notes' do
      it 'notes count is 1 and percentage is 100' do
        expect(user1_note1.body).to eq('test note body')
        expect(user1_note2.body).to eq('test note body 2')
        expect(user1.notes.count).to eq(2)
        expect(reporting.users[:with_notes]).to eq(1)
        expect(reporting.users[:with_notes_percentage]).to eq(100.0)
      end
    end

    context 'when 1 user has notes and 1 has none' do
      it 'notes count is 1 and percentage is 50' do
        expect(user1_note1.body).to eq('test note body')
        expect(user2.email).to eq('test2@example.com')
        expect(user1.notes.count).to eq(1)
        expect(user2.notes.count).to eq(0)
        expect(reporting.users[:with_notes]).to eq(1)
        expect(reporting.users[:with_notes_percentage]).to eq(50.0)
      end
    end

    context 'when 2 users have notes' do
      it 'notes count is 2 and percentage is 100' do
        expect(user1_note1.body).to eq('test note body')
        expect(user2_note.body).to eq('test note body')
        expect(user1.notes.count).to eq(1)
        expect(user2.notes.count).to eq(1)
        expect(reporting.users[:with_notes]).to eq(2)
        expect(reporting.users[:with_notes_percentage]).to eq(100.0)
      end
    end
  end
end
