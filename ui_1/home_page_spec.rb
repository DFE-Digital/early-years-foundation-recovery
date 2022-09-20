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
      end
    end
  end
end
