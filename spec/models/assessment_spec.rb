require 'rails_helper'

RSpec.describe Assessment, type: :model do
  subject(:assessment) do
    create :assessment
  end

  before do
    skip unless Rails.application.migrated_answers?
  end

  specify { expect(assessment).not_to be_passed }
  specify { expect(assessment).not_to be_graded }
end
