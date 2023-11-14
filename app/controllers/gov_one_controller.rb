class GovOneController < ApplicationController

  layout "hero"

  def info
    redirect_to my_modules_path if current_user
  end
end
