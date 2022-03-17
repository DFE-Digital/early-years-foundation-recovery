require_relative '../ui_auto_helper'

describe Pages::Home do
  context 'Just testing home Page instantiation' do

    it "should say 'Hello World' when we call the say_hello method" do
      @home_page = Pages::Home.new
      @home_page.load
      @home_page.header.logo.click
      sleep(2)
      @home_page.header.training_module.click
      sleep(2)
      @home_page.header.sign_in.click
      sleep(2)
    end

  end
end
