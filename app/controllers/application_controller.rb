class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :require_login, :except => [:not_authenticated]
  
  helper_method :current_users_list
  
  protected
  
  def not_authenticated
    redirect_to root_path, :alert => "Please login first."
  end
  
  def current_users_list
    current_users.map {|u| u.email}.join(", ")
  end

  def require_administrator
    unless logged_in? && current_user.role && current_user.role.name == "administrator"
      flash[:warning] = "Only adminstrators can access the #{controller_name} controller"
      redirect_to controller: "home", action: "index"
      false
    else
      true
    end
  end
end
