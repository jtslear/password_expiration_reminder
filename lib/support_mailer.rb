class SupportMailer < Mailer
  SUPPORT_EMAIL = "technicalservices@informed-llc.com"

  def initialize(users_past_due)
    @email = SUPPORT_EMAIL
    @users_past_due = users_past_due
  end

  private

  def text
    email_text = <<-EMAIL
From: Support <#{from_address}>
To: Support <#{to_email_address}>
Importance: high
X-Priority: 10
Subject: AD User Account Report

Users with ** are blah

Support Check these out:
EMAIL
  @users_past_due.each do |user|
    email_text << user
    email_text << "\n"
  end
end
