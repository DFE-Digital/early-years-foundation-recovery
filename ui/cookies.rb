# frozen_string_literal: true
describe 'Cookies policy', er_138: true do
  include_context 'as guest'

  before do
    ui.cookies.load
  end

  it 'then the page is displayed' do
    expect(ui.cookies).to be_displayed
  end

  it 'then the page has a heading' do
    expect(ui.cookies).to have_heading
  end
end
