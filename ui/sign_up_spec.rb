# frozen_string_literal: true

describe 'Sign up page' do
  context 'when unauthenticated' do
    include_context 'as guest'

    before do
      ui.sign_up.load
    end

    it 'can sign up Successfully' do
      ui.sign_up.with_email_and_password
      expect(ui.check_your_email).to have_heading
    end

    it 'is shown a warning message if username is blank' do
      ui.sign_up.with_blank_email_and_password
      expect(ui.sign_up).to have_error_summary_title
    end

    it 'is shown a warning message if username is invalid' do
      ui.sign_up.with_invalid_email_and_password
      expect(ui.sign_up).to have_error_summary_title
    end


  end
end
