class AdministratorsController < ApplicationController
  
  layout 'backend'
  
  # GET /administrators
  def index
    @administrators = Administrator.all(:order => 'name')
  end

  # GET /administrators/new
  def new
    @administrator = Administrator.new
  end

  # GET /administrators/1/edit
  def edit
    @administrator = Administrator.find(params[:id])
  end
  
  # GET /administrators/change_password/1
  def change_password
    @administrator = Administrator.find(params[:id])
    @administrator.password = ""
  end
  
  # POST /administrators/update_password/1
  def update_password
    @administrator = Administrator.find(params[:id])
    
    if @administrator.update_attributes(params[:administrator])
      redirect_to(administrators_url, :notice => 'Administrator password was successfully updated.')
    else
      @administrator.password_confirmation = ""
      @administrator.password = ""
      render :action => "change_password"
    end
  end

  # POST /administrators
  def create
    @administrator = Administrator.new(params[:administrator])
    
    if @administrator.save
      redirect_to(administrators_url, :notice => 'Administrator was successfully created.')
    else
      @administrator.password_confirmation = ""
      @administrator.password = ""
      render :action => "new"
    end
  end

  # PUT /administrators/1
  def update
    @administrator = Administrator.find(params[:id])
    
    if @administrator.update_attributes(params[:administrator])
      redirect_to(administrators_url, :notice => 'Administrator was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /administrators/1
  def destroy
    @administrator = Administrator.find(params[:id])
    @administrator.destroy

    redirect_to(administrators_url)
  end
  
end