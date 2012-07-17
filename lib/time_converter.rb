class TimeConverter
  SECONDS_IN_A_DAY = 86400

  def initialize(time)
    @time = time
  end

  def convert_to_linux
    begin
      unix_time = @time / 10000000 - 11644473600
      unix_time = Time.at(unix_time).to_i
      (unix_time + 11644473600) * 10000000
    rescue Exception => e
      print "error: #{e.message}"
    end
  end

  def self.days_to_seconds(days)
    days * SECONDS_IN_A_DAY
  end
end
