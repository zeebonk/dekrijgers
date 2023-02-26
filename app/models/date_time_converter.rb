class DateTimeConverter 
  
  def self.utc_to_nl(date_time)
		return ActiveSupport::TimeZone.find_tzinfo("Europe/Amsterdam").utc_to_local(date_time)
	end
  
      
  def self.nl_to_utc(date_time)
    ActiveSupport::TimeZone.find_tzinfo("Europe/Amsterdam").local_to_utc(date_time)
  end
 
end
