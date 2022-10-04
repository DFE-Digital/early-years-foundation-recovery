# frozen_string_literal: true

describe 'home page' do
  context 'when unauthenticated' do
    include_context 'as guest'

    before do
        ui.home.load
    end

    it 'is displayed when the user clicks the header logo' do
      ui.home.header.logo.click
      expect(ui.home).to be_displayed
    end

    describe 'footer' do
      it 'links to Terms and conditions' do
        ui.home.footer.terms_and_conditions.click
        expect(ui.terms_and_conditions).to be_displayed
        expect(ui.terms_and_conditions).to have_heading
      end

      it 'links to Cookies' do
        ui.home.footer.cookie_policy.click
        expect(ui.cookies).to be_displayed
        expect(ui.cookies).to have_heading
      end

      it 'links to Privacy policy' do
        ui.home.footer.privacy_policy.click
        expect(ui.privacy_policy).to be_displayed
        expect(ui.privacy_policy).to have_heading
      end

      it 'clicking Learn more and enrol links to About this training course' do
        ui.home.learn_more_and_enrol_button.click
        expect(ui.guest_about_this_training_course).to be_displayed
        expect(ui.guest_about_this_training_course).to have_heading
      end
    end
  end
end
