class FeaturedItemsController < ApplicationController
  
  layout 'backend'

  # GET /featured_items
  def index
    @featured_items = FeaturedItem.all
  end

  # GET /featured_items/new
  def new
    @featured_item = FeaturedItem.new
  end

  # GET /featured_items/1/edit
  def edit
    @featured_item = FeaturedItem.find(params[:id])
  end

  # POST /featured_items
  def create
    @featured_item = FeaturedItem.new(params[:featured_item])

    if @featured_item.save
      redirect_to(featured_items_url, :notice => 'Featured item was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /featured_items/1
  def update
    @featured_item = FeaturedItem.find(params[:id])
    
    if @featured_item.update_attributes(params[:featured_item])
      redirect_to(featured_items_url, :notice => 'Featured item was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /featured_items/1
  def destroy
    @featured_item = FeaturedItem.find(params[:id])
    @featured_item.destroy

    redirect_to(featured_items_url)
  end
end