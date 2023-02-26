class HomeController < ApplicationController
  
  # GET /home
  def index
    @featured_items = FeaturedItem.all.shuffle
    @blog_posts = BlogPost.for_homepage
    @gigs = Gig.all(:order=>"start")
    @tweets = Twittery.new("dekrijgers", "tijdelijk").get_user_timeline("dekrijgers", 4)
  end
  
end
