RSpec.describe 'Rack System Smoke Test', type: :system do
  it 'works' do
    visit '/'

    expect(page).to have_text 'Your application is ready'
  end
end
