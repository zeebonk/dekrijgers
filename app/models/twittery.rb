require 'net/http'
require 'yaml'
require 'rubygems'
require 'rexml/document'

class Twittery
  
  TIMEOUT_SECONDS = 30
 
  def initialize(user, pass)
    @username = user
    @password = pass
  end

  def get_user_timeline(user, count)
    timeline = user_timeline(user, count, "xml")
    doc = REXML::Document.new timeline
    
    texts = REXML::XPath.each(doc, '/statuses/status/text/text()') { |el| el }
    usernames = REXML::XPath.each(doc, '/statuses/status/user/screen_name/text()') { |el| el }
    images = REXML::XPath.each(doc, '/statuses/status/user/profile_image_url/text()') { |el| el }
    
    tweets = []
    (0..texts.count).each do |i|
      if !texts[i].blank?
        tweets << Tweet.new(usernames[i], texts[i], images[i])
      end
    end
    
    if tweets.count > count
      return tweets[0, count]
    else
      return tweets
    end
  end
  
private
  
  # status must be between 1 and 160 characters
  def update_status(status, format = 'json')
    return "status must been less than 160 characters." if status.length > 160
    return "status must have something in it..." if status.length < 1
    
    api_url = 'http://twitter.com/statuses/update.' + format
    url = URI.parse(api_url)
    req = Net::HTTP::Post.new(url.path)
    req.basic_auth(@username, @password)
    req.set_form_data({ 'status'=> status }, ';')
    res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
    return res
  end
  
  def show_post(id, format = 'json')
    return "id must be invalid or not nil" if id.nil?
    api_url = 'http://twitter.com/statuses/show/' + id.to_s + '.' + format
    url = URI.parse(api_url)
    req = Net::HTTP::Post.new(url.path)
    req.basic_auth(@username, @password)
    req.set_form_data({ 'id'=> id }, ';')
    res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
    return res
  end
  
  def destroy_post(id, format = 'json')
    api_url = 'http://twitter.com/statuses/destroy/' + id.to_s + '.' + format
    url = URI.parse(api_url)
    req = Net::HTTP::Post.new(url.path)
    req.basic_auth(@username, @password)
    req.set_form_data({ 'id'=> id }, ';')
    res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
    return res
  end
  
  def friends_timeline(user_id, format = 'json')
    api_url = ''
    unless user_id.nil?
      api_url = 'http://twitter.com/statuses/friends_timeline/' + user_id + '.' + format
    else
      api_url = 'http://twitter.com/statuses/friends_timeline.' + format
    end
    
    url = URI.parse(api_url)
    req = Net::HTTP::Get.new(url.path)
    req.basic_auth(@username, @password)
    res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
    return res 
  end
  
  def user_timeline(user_id = @username, count = 20, format = 'json')
    return "count must been 20 or less!" if count > 20
    return "count must been 1 or more" if count < 1
    
    api_url = 'http://twitter.com/statuses/user_timeline/' + user_id + "." + format + "?count=" + count.to_s
    url = URI.parse(api_url)
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req).read_body }
    return res
  end
  
  def public_timeline(format = 'json')
    api_url = 'http://twitter.com/statuses/public_timeline.' + format
    url = URI.parse(api_url)
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
    return res
  end
  
  def post_pic(filename, message)
    
    return "#{filename} is not a picture" unless validate_pic(filename)

    # Open the actually picture that you want to send
    file = File.open(filename, "rb")

    # setting the post parameters
    params = Hash.new
    params["media"] = file
    params["username"] = @username
    params["password"] = @password
    params["message"] = message

    # make a MultipartPost
    mp = Multipart::MultipartPost.new

    # Get both the headers and the query ready,
    # given the new MultipartPost and the params
    # Hash
    query, headers = mp.prepare_query(params)

    # done with file now
    file.close

    # Using the TwitPic API to upload picture
    url = URI.parse("http://twitpic.com/api/uploadAndPost")

    # Do the actual POST, given the right inputs
    res = post_form(url, query, headers)

    # res holds the response to the POST
    case res
    when Net::HTTPSuccess
      puts "YAY! Status and Pic Uploaded!"
    when Net::HTTPInternalServerError
      raise "Server blew up!"
    else
      raise "Unknown Error #{res}: #{res.inspect}"
    end
  end
  
  def post_form(url, query, headers)
      Net::HTTP.start(url.host, url.port) {|con|
        con.read_timeout = TIMEOUT_SECONDS
        begin
          return con.post(url.path, query, headers)
        rescue => e
          puts "POSTING Failed #{e}... #{Time.now}"
        end
      }
  end
  
  def validate_pic(filename)
    valid_exts = [".jpg", "jpeg", ".gif", ".bmp", ".png"]
    
    valid_exts.each do |ext|
      unless filename.index(ext).nil?
        file = File.open(filename, "rb")
        return false if file.empty?
      end
    end
    
  end
  
end