RSpec.shared_examples 'a Govspeak page' do
  before { visit(path) }

  it 'is displayed' do
    expect(page.source).to include '<div role="note" aria-label="Warning" class="application-notice help-notice">'
    expect(page).to have_text 'Warning: Govspeak test'
  end
end
