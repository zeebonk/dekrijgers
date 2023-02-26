class BlogPost < ActiveRecord::Base
  
  belongs_to :administrator
  
  before_destroy :remove_image
  
  validate :image_supported
  validates_presence_of :title, :content, :administrator
  
  def self.for_homepage
    BlogPost.all(:order => 'created_at DESC')
  end
  
  def image=(value)
    if value != nil
      begin
        picture = UploadPicture.new(value)
        picture.create_large_image
        picture.create_small_image
        self[:image] = picture.filename
      rescue
        self[:image] = "\"" + value.original_filename + "\" not supported"
      end
    end
  end
  
  def image_supported
    return if image.nil?
    
    if image.include?("not supported")
      errors.add(:image, image)
      self[:image] = ""
    end
  end
  
  def remove_image
    FileUtils.remove_file "#{RAILS_ROOT}/public/images/small/#{image}", true
    FileUtils.remove_file "#{RAILS_ROOT}/public/images/large/#{image}",  true
    self[:image] = ""
  end
  
end
