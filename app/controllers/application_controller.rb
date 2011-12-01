class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!

  def aunthenticate_manager!
    redirect_to user_sign_in_path unless current_user.kind_of? Manager
  end
end
