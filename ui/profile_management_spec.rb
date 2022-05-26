# frozen_string_literal: true

describe 'Profile management' do
  include_context 'with user'

  before do
    ui.my_account.load
  end

  describe 'Your details' do
    it 'edit first name' do
      expect(ui.my_account).to be_displayed
      ui.my_account.edit_name.click
      expect(ui.edit_name).to be_displayed
      ui.edit_name.first_name_field.set 'Peter'
      ui.edit_name.button.click
      expect(ui.my_account).to be_displayed
      expect(ui.my_account.name).to have_text 'Peter'
    end
  end
end
