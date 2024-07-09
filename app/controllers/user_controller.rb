class UserController < ApplicationController
  before_action :authenticate_registered_user!

  def show
    track('profile_page')
  end
end
