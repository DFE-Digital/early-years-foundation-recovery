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
end
