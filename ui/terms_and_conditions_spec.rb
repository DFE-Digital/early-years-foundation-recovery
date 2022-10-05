# frozen_string_literal: true
describe 'Terms and conditions', er_136: true do
  include_context 'as guest'

  before do
    ui.terms_and_conditions.load
  end

  it 'then the page is displayed' do
    expect(ui.terms_and_conditions).to be_displayed
  end

  it 'then the page has a heading' do
    expect(ui.terms_and_conditions).to have_heading
  end
end
