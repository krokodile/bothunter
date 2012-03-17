class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :authenticate_user! <- BAD PATTERN

  def authenticate_manager!
    redirect_to new_user_session_path unless current_user.manager?
  end
end
