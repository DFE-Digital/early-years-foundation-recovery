class GovOneController < ApplicationController
  layout 'hero'

  def show
    redirect_to my_modules_path if current_user
  end
end
