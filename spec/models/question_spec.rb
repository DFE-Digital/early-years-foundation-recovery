require 'rails_helper'

RSpec.describe Question, type: :model do
  let(:question) { described_class.find_by!(name: :test, training_module: :test, question: :one_from_many)}

  specify { expect(question.name).to eq(:one_from_many) }
end