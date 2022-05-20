# frozen_string_literal: true

describe 'Terms and conditions', er_136: true do
  let(:ui) { Ui.new }

  before do
    ui.terms_and_conditions.load
  end

  after do
    # Capybara.current_session.driver.quit
    browser = Capybara.current_session.driver.browser
    browser.manage.delete_all_cookies
  end

  context 'navigated to by user' do
    it 'then the Terms and conditions is displayed' do
      expect(ui.terms_and_conditions).to have_xpath("//h1[contains(text(),'Terms and conditions')]")
    end
  end
end