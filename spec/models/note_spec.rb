require 'rails_helper'

RSpec.describe Note, type: :model do
  let(:note) { create :note, body: 'This is the body' }

  it 'is valid' do
    expect(build(:note)).to be_valid
  end

  it 'encrypts the body' do
    expect(note.body_before_type_cast).not_to eq('This is the body')
  end
end
