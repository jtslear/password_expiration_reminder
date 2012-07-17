class UserMailer < Mailer
  def new(name, email, days_to_lockout)
    @name = name
    @email = email
    @days_to_lockout = days_to_lockout
  end

  private

  def text
    email_string = <<-EMAIL
From: Support <#{FROM_ADDRESS}>
To: #{name} <#{email}>
Importance: high
X-Priority: 10
Subject: ** NOTICE: Your password is about to expire! **

Hello #{name},

This message is to inform you that your InforMed domain password will be expiring in #{days_until_lockout} days.  This password affects your ability to log on to your computer, Zimbra, and Interaction Client.

Telecommuters: To change your password, be sure you are logged on to the VPN then press Ctrl + Alt + Del and select \"Change Password.\"  

In-house employees: To change your password, press Ctrl + Alt + Del and select \"Change Password.\" 

Be sure the new password meets InforMed's complexity requirements: minimum of 8 characters, uppercase and lowercase letters, and a number or punctuation.

Thank you.

InforMed Technical Services
866.655.7535
    EMAIL
  end
end
