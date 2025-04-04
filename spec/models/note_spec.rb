require 'rails_helper'

RSpec.describe Note, type: :model do
  let(:note) { create :note, body: 'This is the body' }
  let(:blank_note) { create :note, body: '' }
  let(:whitespace_note) { create :note, body: " \n \n \n" }

  it 'is valid' do
    expect(build(:note)).to be_valid
  end

  it 'encrypts the body' do
    expect(note.body_before_type_cast).not_to eq('This is the body')
  end

  context 'when the body has content' do
    specify { expect(note).to be_filled }
  end

  context 'when the body has no content' do
    specify { expect(blank_note).not_to be_filled }
    specify { expect(whitespace_note).not_to be_filled }
  end

  describe '#logged_at' do
    it 'returns formatted updated_at date' do
      expect(note.logged_at).to eq(note.updated_at.to_date.strftime('%-d %B %Y'))
    end
  end

  describe 'updated_at timestamp' do
    it 'changes when the note is updated' do
      old_time = note.updated_at
      travel 1.minute do
        note.update!(body: 'Updated content')
        expect(note.updated_at).to be > old_time
      end
    end
  end
end
