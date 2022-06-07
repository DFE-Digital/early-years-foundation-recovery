require 'rails_helper'

RSpec.describe 'Following registration journey' do
  let(:user) { create :user }

  context 'when on the check your email page' do
    before do
      visit "my-account/check_email_confirmation?email=#{user.email}"
    end

    context 'and can click on "I haven\'t receieved the email" link' do
      it 'taken to "resend your confirmation" page' do
        click_on 'Send me another email', visible: :hidden
        
        expect(page.current_path).to eq('/users/confirmation/new')
        expect(page).to have_text('Resend your confirmation')
      end
    end
      
    context 'and can click on the "I don\'t have access to the email" link' do
      it 'I am taken to the ‘create your account’ page to re-register' do
        click_on 'create a new account', visible: :hidden
        
        expect(page.current_path).to eq('/users/sign_up')
        expect(page).to have_text('Create an early years training account')
      end
    end
      
    context 'and can click on the ‘other problems’ link' do
      it 'taken to the ‘MS form to contact us’' do
        expect(page).to have_link 'contact us', href: '#', visible: :hidden
      end
    end
    
    context 'and navigate to "resend your confirmation"' do
      it 'can click on a back button to be taken to the "check your email" page' do
        click_on 'Send me another email', visible: :hidden
        click_on 'Go back to check your email'
        expect(page).to have_text("Check your email")
      end
    end
  end
  
  context 'when on the ‘resend your confirmation’ page' do
    before do
      visit "/users/confirmation/new"
    end

    context 'and can enter email address and click send' do
      it 'taken to the confirmation email sent page' do
        fill_in "Email address", with: user.email
        click_on 'Send email'

        expect(page).to have_text("Check your email")
      end
    end
    
  end
end
