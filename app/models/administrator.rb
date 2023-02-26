class Administrator < ActiveRecord::Base
  
  has_many :blog_posts, :dependent => :destroy
  
  validates_uniqueness_of :name, :case_sensitive => false
  validates_presence_of :name, :password
  validates_confirmation_of :password
  
  def password=(value)
    if value.blank?
      self[:password] = ""
    else
      self[:password] = Administrator.sha1_with_salt(value)
    end
  end
  
  def password_confirmation
    @password_confirmation
  end
  
  def password_confirmation=(value)
    if value.blank?
      @password_confirmation = ""
    else
      @password_confirmation = Administrator.sha1_with_salt(value)
    end
  end
  
  def self.sha1_with_salt(value)
    Digest::SHA1.hexdigest("God Bless Our Homeland Ghana" + value + "Adam Dalgliesh")
  end
  
  def self.authenticate(name, password)
    Administrator.find_by_name_and_password(name, Administrator.sha1_with_salt(password))
  end
  
end
