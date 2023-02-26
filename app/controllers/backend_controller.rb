class BackendController < ApplicationController
  
  layout 'backend'
  
  def sign_in
    
  end
  
  def sign_out
    session[:administrator_id] = nil
  end
  
  def index
  
  end
  
  def authenticate 
    administrator = Administrator.authenticate(params[:name], params[:password])
    
    if administrator.nil?
      flash[:error] = "Wrong username/password combination."
      render(:action => 'sign_in')
    else
      flash[:notice] = "#{administrator.name} succesfully signed in."
      session[:administrator_id] = administrator.id
      redirect_to(:action => 'index')
    end
  end
  
end
