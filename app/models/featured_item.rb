class FeaturedItem < ActiveRecord::Base
  
  before_destroy :remove_image
  
  validate :image_supported
  validates_presence_of :title, :content, :image

  def image=(value)
    if value != nil
      #begin
        picture = UploadPicture.new(value)
        picture.create_large_image
        picture.create_medium_image
        remove_image
        self[:image] = picture.filename
      #rescue
        #self[:image] = "\"" + value.original_filename + "\" not supported"
      #end
    end
  end
  
  def image_supported
    if image.include?("not supported")
      errors.add(:image, image)
      self[:image] = FeaturedItem.find(id).image if id
    end
  end
  
  def remove_image
    FileUtils.remove_file "#{RAILS_ROOT}/public/images/medium/#{image}", true
    FileUtils.remove_file "#{RAILS_ROOT}/public/images/large/#{image}",  true
    self[:image] = ""
  end

end
