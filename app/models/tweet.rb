require 'rexml/document'

class Tweet

  attr_accessor :username, :text, :image
  
  def initialize(user, txt, img)
    @username = user
    @text = txt
    @image = img
  end
  
end
