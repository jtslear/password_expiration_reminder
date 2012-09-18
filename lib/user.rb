class User
  attr_reader :name, :email, :lockout_days

  def initialize(name, email, lockout_days)
    @name = name
    @email = emai
    @lockout_days = lockout_days
  end

  def to_s
    if lockout_days > 0
      "Name: #{@name}"
    else
      "**Name: #{@name} E-mail: #{@email} Days: #{@lockout_days}**"
    end
  end

  def notify
    Mailer.new(@name, @email, days_to_lockout).deliver
  end
end
