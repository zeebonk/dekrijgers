class BlogPostsController < ApplicationController

  layout 'backend'
  
  # GET /blog_posts
  def index
    @blog_posts = BlogPost.all(:order => 'created_at DESC')
  end

  # GET /blog_posts/new
  def new
    @blog_post = BlogPost.new
  end

  # GET /blog_posts/1/edit
  def edit
    @blog_post = BlogPost.find(params[:id])
  end

  # POST /blog_posts
  def create
    @blog_post = BlogPost.new(params[:blog_post])
    @blog_post.administrator_id = session[:administrator_id]
    
    if @blog_post.save
      redirect_to(blog_posts_url, :notice => 'Blog post was successfully created.')
    else
      @blog_post.remove_image
      render :action => "new"
    end
  end

  # PUT /blog_posts/1
  def update
    @blog_post = BlogPost.find(params[:id])
    
    @blog_post.remove_image if params[:remove_image]
    
    if @blog_post.update_attributes(params[:blog_post])
      redirect_to(blog_posts_url, :notice => 'Blog post was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /blog_posts/1
  def destroy
    @blog_post = BlogPost.find(params[:id])
    @blog_post.destroy

    redirect_to(blog_posts_url)
  end
end