class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  helper_method :current_user, :logged_in?
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def logged_in?
    !!current_user
  end
  
  def require_user
    if !logged_in?
      flash[:danger] = "You must be logged in to perform that action"
      redirect_to root_path
    end
  end 
  
  #redirect to homepage on error
  rescue_from ActionView::MissingTemplate, :with => :template_not_found
  rescue_from ActiveRecord::RecordNotFound, :with => :template_not_found
  rescue_from ActiveRecord::StatementInvalid, :with => :template_not_found

  private
  
    def template_not_found
      redirect_to root_path
    end
end
