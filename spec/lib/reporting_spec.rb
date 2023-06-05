require 'rails_helper'
require 'reporting'

RSpec.describe Reporting do
  describe '.users' do
    subject(:reporting) { Class.new { extend Reporting } }

    let(:user1) { create(:user, :registered, email: 'test1@example.com') }
    let(:user2) { create(:user, :registered, email: 'test2@example.com') }

    describe '.users' do
      let(:with_notes) { reporting.users[:with_notes] }
      let(:with_notes_percentage) { reporting.users[:with_notes_percentage] }
      let(:without_notes) { reporting.users[:without_notes] }
      let(:without_notes_percentage) { reporting.users[:without_notes_percentage] }

      let(:note_1) { user1.notes.create(body: 'test note body') }
      let(:note_2) { user1.notes.create(body: 'test note body 2') }
      let(:note_3) { user2.notes.create(body: 'test note body') }

      context 'when 0 users or notes exist' do
        it 'with_notes is 0 and percentage is NaN' do
          expect(with_notes).to be_zero
          expect(with_notes_percentage).to be_nan
        end
      end

      context 'when there are users but no notes' do
        before do
          user1
        end

        it 'with_notes count and percentage are 0 and without notes is 100%' do
          expect(with_notes).to eq(0)
          expect(with_notes_percentage).to be_zero
          expect(without_notes).to eq(1)
          expect(without_notes_percentage).to eq(100.0)
        end
      end

      context 'when there is a saved note but the body is empty' do
        let(:blank_note) { user1.notes.create(body: '') }
        let(:whitespace_note) { user1.notes.create(body: " \n \n \n") }

        before do
          blank_note
          whitespace_note
        end

        it 'the note is not counted' do
          expect(with_notes).to be_zero
          expect(with_notes_percentage).to be_zero
          expect(without_notes).to eq(1)
          expect(without_notes_percentage).to eq(100.0)
        end
      end

      context 'when all users have notes' do
        before do
          note_1
        end

        it 'percentage is 100' do
          expect(user1.notes.count).to eq(1)
          expect(with_notes).to eq(1)
          expect(with_notes_percentage).to eq(100.0)
          expect(without_notes).to be_zero
          expect(without_notes_percentage).to be_zero
        end
      end

      context 'when there is 1 user with multiple notes' do
        before do
          note_1
          note_2
        end

        it 'notes count is 1 and percentage is 100' do
          expect(with_notes).to eq(1)
          expect(with_notes_percentage).to eq(100.0)
          expect(without_notes).to be_zero
          expect(without_notes_percentage).to be_zero
        end
      end

      context 'when half of users have notes' do
        before do
          note_1
          user2
        end

        it 'percentage is 50' do
          expect(with_notes).to eq(1)
          expect(with_notes_percentage).to eq(50.0)
          expect(without_notes).to eq(1)
          expect(without_notes_percentage).to eq(50.0)
        end
      end

      context 'when 2 users have notes' do
        before do
          note_1
          note_3
        end

        it 'notes count is 2 and percentage is 100' do
          expect(with_notes).to eq(2)
          expect(with_notes_percentage).to eq(100.0)
          expect(without_notes).to be_zero
          expect(without_notes_percentage).to be_zero
        end
      end

      context 'when a user is closed' do
        before do
          note_1
        end

        it 'their notes are deleted' do
          user1.redact!
          expect(user1.first_name).to eq('Redacted')
          expect(with_notes).to be_zero
          expect(with_notes_percentage).to be_nan
          expect(without_notes).to be_zero
          expect(without_notes_percentage).to be_nan
        end
      end
    end
  end
end
