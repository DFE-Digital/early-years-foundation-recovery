# frozen_string_literal: true

describe 'Privacy Page', er_137: true do
  let(:ui) { Ui.new }

  before do
    ui.privacy_policy.load
  end

  after do
    # Capybara.current_session.driver.quit
    browser = Capybara.current_session.driver.browser
    browser.manage.delete_all_cookies
  end

  context 'navigated to by user' do
    it 'then the Privacy page is displayed' do
       expect(ui.privacy_policy).to have_xpath("//h1[contains(text(),'Privacy policy')]")
    end
  end
end