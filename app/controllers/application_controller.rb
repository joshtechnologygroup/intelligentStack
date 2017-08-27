class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :current_user_id

  def current_user_id
    @current_user_id = 6534673
  end
end
