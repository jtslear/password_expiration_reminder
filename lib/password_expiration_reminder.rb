#!/usr/bin/ruby -w
class Connection
  def bind(x, y)
  end
  def perror(x)
  end
end
require 'rubygems'

#require 'net-ldap'
#require 'net/smtp'

$HOST = 'splat.local'
$PORT =  "23" #$PORT = LDAP::LDAP_PORT
$SSLPORT = "43" #$SSLPORT = LDAP::LDAPS_PORT

def email_support(users_who_were_notified)
  SupportMailer.new(users_who_were_notified).deliver
end

users_who_need_reset = []

conn = Connection.new #  LDAP::Conn.new($HOST, $PORT)
conn.bind('cn=ldap searcher,ou=Service_Accounts,ou=Accounts__Groups,dc=splat,dc=local', 'splat.local')

base = 'ou=InforMed_Accounts,dc=splat,dc=local'
scope = nil #LDAP::LDAP_SCOPE_SUBTREE
filter = '(objectclass=*)'
attrs = ['cn', 'pwdLastSet', 'mail']

conn.perror("bind")
begin
  results = []
  conn.search(base, scope, filter, attrs) do |entry|
    passwd_last_set = entry.vals('pwdLastSet')
    email_set = entry.vals('mail')
    if passwd_last_set and email_set
      active_directory_password_last_set = entry.vals('pwdLastSet').first.to_i
      time_converter = TimeConverter.new(input)
      time_password_set = time_converter.convert_to_linux
      password_calculator = PasswordPolicyCalculator.new(time_password_set)

      if password_calculator.password_reset_needed?
        users_email = entry.vals('mail').first.to_s
        users_name = entry.vals('cn').first.to_s
        user = User.new(users_name, users_email, lockout_days)
        if password_calculator.inside_warning_period
          user.notify
        end
        users_who_need_reset << user
      end
    end
  end
rescue Exception => e #LDAP::ResultError
  conn.perror("search")
  exit
end
conn.perror("search")
conn.unbind

email_support(users_who_need_reset)
