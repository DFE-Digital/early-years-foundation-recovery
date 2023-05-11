# frozen_string_literal: true

# ER-124: 2. Sign-in error messages for invalid or not recognised credentials

describe 'Sign in page' do
  context 'when unauthenticated' do
    include_context 'as guest'

    before do
      ui.sign_in.load
    end

    it 'Warning is displayed when the user clicks login with blank username' do
      ui.sign_in.with_blank_email_and_password
      expect(ui.sign_in).to have_warning_title
    end

    it 'Warning is displayed when the user clicks login with invalid username' do
      ui.sign_in.with_invalid_email_and_password
      expect(ui.sign_in).to have_warning_title
    end

    it 'is shown expanded Help menu' do
      sleep(10)
      ui.sign_in.problem_signing_in.click
      expect(ui.sign_in).to have_content 'I have forgotten my password'
      expect(ui.sign_in).to have_content 'receive confirmation instructions?'
      expect(ui.sign_in).to have_content 'Other problems signing in'
    end

    it 'is shown I have forgotten my Password page' do
      sleep(10)
      ui.sign_in.problem_signing_in.click
      expect(ui.sign_in).to have_content 'I have forgotten my password'
      ui.sign_in.forgotten_my_password_link.click
      expect(ui.forgotten_my_password).to have_heading
    end
  end
end
