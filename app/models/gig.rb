class Gig < ActiveRecord::Base
  
  validates_presence_of :name, :start

  def start
    DateTimeConverter.utc_to_nl(self[:start])
  end
  
  def start=(value)
    self[:start] = DateTimeConverter.nl_to_utc(value)
  end

end