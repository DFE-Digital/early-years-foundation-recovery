class Users::SessionsController < Devise::SessionsController
  layout 'hero'

  def new
    render 'gov_one'
  end
end
