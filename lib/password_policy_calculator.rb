class PasswordPolicyCalculator
  SECONDS_IN_A_DAY = 86400

  def initialize(time_password_set)
    @time_password_set = time_password_set
  end

  def password_reset_needed?
    past_warning_period > 0
  end

  def valid_password_period
    TimeConverter.days_to_seconds(90) + @time_password_set
  end

  def warn_period
    valid_password_period - TimeConverter.days_to_seconds(14)
  end

  def days_till_lockout
    valid_password_period - Time.now.to_i / SECONDS_IN_A_DAY
  end

  def past_warning_period
    Time.now.to_i >= warn_period
  end

  def inside_warning_period
    days_till_lockout
  end
end
