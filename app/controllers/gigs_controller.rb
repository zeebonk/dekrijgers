class GigsController < ApplicationController

  layout 'backend'

  # GET /gigs
  def index
    @gigs = Gig.all(:order => 'start')
  end

  # GET /gigs/new
  def new
    @gig = Gig.new
    @gig.start = DateTimeConverter::utc_to_nl(Time.new.utc)
  end

  # GET /gigs/1/edit
  def edit
    @gig = Gig.find(params[:id])
  end

  # POST /gigs
  def create
    @gig = Gig.new(params[:gig])

    if @gig.save
      redirect_to(gigs_url, :notice => 'Gig was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /gigs/1
  def update
    @gig = Gig.find(params[:id])

    if @gig.update_attributes(params[:gig])
      redirect_to(gigs_url, :notice => 'Gig was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /gigs/1
  def destroy
    @gig = Gig.find(params[:id])
    @gig.destroy

    redirect_to(gigs_url)
  end
end
