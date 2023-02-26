# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :protect_backend

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  def protect_backend
    return if params[:controller] == "home"
    return if params[:controller] == "backend" && params[:action] == "sign_in"
    return if params[:controller] == "backend" && params[:action] == "authenticate"
    
    return if !session[:administrator_id].blank?
    
    redirect_to(:controller => "backend", :action => "sign_in")
  end
end
