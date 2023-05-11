# frozen_string_literal: true

describe 'Privacy Page' do
  include_context 'as guest'

  before do
    ui.privacy_policy.load
  end

  it 'then the page is displayed' do
    expect(ui.privacy_policy).to be_displayed
  end

  it 'then the page has a heading' do
    expect(ui.privacy_policy).to have_heading
  end
end
