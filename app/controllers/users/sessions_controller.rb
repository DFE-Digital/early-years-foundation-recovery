class Users::SessionsController < Devise::SessionsController
  layout 'hero'

  def new
    render 'gov_one'
  end

  # @return [String, nil]
  def sign_in_test_user
    sign_in_and_redirect User.test_user if User.test_user
  end
end
