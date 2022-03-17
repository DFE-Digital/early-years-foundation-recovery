require_relative '../ui_auto_helper'

describe Home do
  context 'Just testing home Page instantiation' do

    it "should say 'Hello World' when we call the say_hello method" do
      @home_page = Pages::Home.new
      @home_page.load
    end

  end
end
