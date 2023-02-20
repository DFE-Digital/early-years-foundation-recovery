# frozen_string_literal: true

describe 'About this training course' do
  include_context 'as guest'

  before do
    ui.guest_about_this_training_course.load
  end

  it 'then navigating back the links do not duplicate' do
    ui.guest_about_this_training_course.sign_in_link.click
    sleep(3)
    expect(ui.sign_in).to be_displayed
    ui.sign_in.go_back
    expect(ui.guest_about_this_training_course).to be_displayed
    expect(ui.guest_about_this_training_course).to have_content('Show all sections', count: 2)
  end

  it 'then collapsed Accordions expand when show all sections is select' do
    ui.guest_about_this_training_course.show_all_sections.click
    expect(ui.guest_about_this_training_course).to have_content('Hide all sections')
    expect(ui.guest_about_this_training_course).to have_content('Hide')
  end

  it 'then Expanded Accordions can be collapsed' do
    ui.guest_about_this_training_course.show_all_sections.click
    expect(ui.guest_about_this_training_course).to have_content('Hide all sections')
    ui.guest_about_this_training_course.hide_all_sections.click
    expect(ui.guest_about_this_training_course).to have_content('Show all sections')
  end
end
