RSpec.shared_context 'with user' do
  let(:ui) { Ui.new }

  let(:browser) { Capybara.current_session.driver.browser }

  before do
    ui.home.load
    ui.home.header.sign_in.click
    ui.sign_in.with_email_and_password
  end

  # Capybara.current_session.driver.quit
  after do
    browser.manage.delete_all_cookies
  end
end
