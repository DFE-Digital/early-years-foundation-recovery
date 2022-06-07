require 'rails_helper'

RSpec.describe UserTraining do
  subject(:learning) { described_class.new(user: user) }

  let(:user) { create(:user) }

  it '#course_completed?' do
    expect(learning.course_completed?).to be false
  end
end
