# frozen_string_literal: true

describe 'Static pages' do
  include_context 'as guest'
  
  it "Accessibility statement" do
    ui.static_page.load(page_name: 'accessibility-statement')
    expect(ui.static_page).to be_displayed(page_name: 'accessibility-statement')
      .and have_heading(text: 'Accessibility statement')
      .and be_all_there
  end
  
  it "Wifi and data" do
    ui.static_page.load(page_name: 'wifi-and-data')
    expect(ui.static_page).to be_displayed(page_name: 'wifi-and-data')
      .and have_heading(text: 'Free internet, wifi and data resources')
      .and be_all_there
  end

  it "Privacy policy" do
    ui.static_page.load(page_name: 'privacy-policy')
    expect(ui.static_page).to be_displayed(page_name: 'privacy-policy')
      .and have_heading(text: 'Privacy policy')
      .and be_all_there
  end

  it "Terms and conditions" do
    ui.static_page.load(page_name: 'terms-and-conditions')
    expect(ui.static_page).to be_displayed(page_name: 'terms-and-conditions')
      .and have_heading(text: 'Terms and conditions')
      .and be_all_there
  end
  
  it "Sitemap" do
    ui.static_page.load(page_name: 'sitemap')
    expect(ui.static_page).to be_displayed(page_name: 'sitemap')
      .and have_heading(text: 'Sitemap')
      .and be_all_there
  end
end
