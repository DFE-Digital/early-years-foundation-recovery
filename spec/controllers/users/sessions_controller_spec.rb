require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  it 'redirects to my modules for registered user' do
    user = create :user, :registered, :emails_opt_in
    post :create, params: { user: { email: user.email, password: 'StrongPassword123' } }
    expect(response).to redirect_to(my_modules_path)
  end

  it 'redirects to whats new for registered user with flag turned on' do
    user = create :user, :registered, display_whats_new: true
    post :create, params: { user: { email: user.email, password: 'StrongPassword123' } }
    expect(response).to redirect_to(static_path('whats-new'))
  end

  context 'when user email preferences are nil' do
    it 'redirects to update email preferences' do
      user = create :user, :registered
      post :create, params: { user: { email: user.email, password: 'StrongPassword123' } }
      expect(response).to redirect_to(email_preferences_path)
    end
  end

  it 'redirects to new registration if previously registered' do
    user = create :user, :registered, registration_complete: false, private_beta_registration_complete: true
    post :create, params: { user: { email: user.email, password: 'StrongPassword123' } }
    expect(response).to redirect_to(static_path('new-registration'))
  end
end
