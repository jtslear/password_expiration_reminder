class Mailer
  SMTP_SERVER = "zimbra.informed-llc.com"
  SMPT_PORT = 25
  FROM_ADDRESS = "support@informed-llc.com"

  def initialize(@email)
    @email = email
  end

  def deliver
    Net::SMTP.start(SMTP_SERVER, SMTP_PORT) do |smtp|
      smtp.send_message text, FROM_ADDRESS, @email
    end
  end

  private

  def text
    ""
  end
end
