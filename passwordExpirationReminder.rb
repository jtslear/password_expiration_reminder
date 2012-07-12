#!/usr/bin/ruby -w

require 'ldap'
require 'net/smtp'

$HOST = 'splat.local'
$PORT = LDAP::LDAP_PORT
$SSLPORT = LDAP::LDAPS_PORT

def win_to_unix_epoch_v2(input)
	# input is 100 nano seconds since Jan 1, 1601
	# Let's convert that to seconds to make my life easier
	begin
		windows_time = input
		unix_time = windows_time/10000000-11644473600
		ruby_time = Time.at(unix_time)
		unix_time2 = ruby_time.to_i
		current_time = Time.now.to_i
		windows_time2 = (unix_time2 + 11644473600) * 10000000
	rescue Exception => e
		print "error: #{e.message}"
	end
	#return unix_time2
	time_password_set = unix_time2
	#print "Password Last Set: ",time_password_set,"\n"

	# Lets grab our current time since epoch
	current_time = Time.now.to_i

	# The following in seconds:
	fourteen_days = 86400 * 14
	ninety_days  = 86400 * 90

	# Our policy is to change passwd's every 90 days
	valid_password_period = ninety_days + time_password_set
	# Lets find the warn time, 14 days ahead of expiration
	warn_period = valid_password_period - fourteen_days
	# Find out how much time, in days, is left before lock out
	days_till_lockout = (valid_password_period - current_time)/86400 

	# is the current time greater than ninetyMinusFourteenLastPasswdSetTime?
	if current_time >= warn_period 
		return days_till_lockout
	else 
		return 0
	end
end

def email_the_person(u_name,u_email,days_to_lockout)

	smtp_server = "zimbra.informed-llc.com"
	smtp_port = 25
	from_address = "support@informed-llc.com"

	full_name = u_name
	to_email_address = u_email
	days_until_lockout = days_to_lockout
	email_string = "From: Support <#{from_address}>
To: #{full_name} <#{to_email_address}>
Importance: high
X-Priority: 10
Subject: ** NOTICE: Your password is about to expire! **

Hello #{full_name},

This message is to inform you that your InforMed domain password will be expiring in #{days_until_lockout} days.  This password affects your ability to log on to your computer, Zimbra, and Interaction Client.
 
Telecommuters: To change your password, be sure you are logged on to the VPN then press Ctrl + Alt + Del and select \"Change Password.\"  
 
In-house employees: To change your password, press Ctrl + Alt + Del and select \"Change Password.\" 
 
Be sure the new password meets InforMed's complexity requirements: minimum of 8 characters, uppercase and lowercase letters, and a number or punctuation.
 
Thank you.
 
InforMed Technical Services
866.655.7535"

	Net::SMTP.start(smtp_server, smtp_port) do |smtp|
		smtp.send_message email_string, from_address, to_email_address 
	end
end

def email_support(array_input)

	smtp_server = "zimbra.informed-llc.com"
	smtp_port = 25
	from_address = "support@informed-llc.com"

	to_email_address = "technicalservices@informed-llc.com"
	email_string = "From: Support <#{from_address}>
To: Support <#{to_email_address}>
Importance: high
X-Priority: 10
Subject: AD User Account Report

Support Check these out:
"
	array_input.each { |i| email_string << i}

	Net::SMTP.start(smtp_server, smtp_port) do |smtp|
		smtp.send_message email_string, from_address, to_email_address 
	end
end

audit_email_msg = "\nThe following have not changed their passwords for the specified day\n"
people_emailed = "\nThe following people have been notified about upcoming password expirations:\n"
people_with_no_password_changed_for_a_long_time = 0

conn = LDAP::Conn.new($HOST, $PORT)
conn.bind('cn=ldap searcher,ou=Service_Accounts,ou=Accounts__Groups,dc=splat,dc=local', 'splat.local')

base = 'ou=InforMed_Accounts,dc=splat,dc=local'
scope = LDAP::LDAP_SCOPE_SUBTREE
filter = '(objectclass=*)'
attrs = ['cn', 'pwdLastSet', 'mail']

conn.perror("bind")
begin
	results = []
	conn.search(base, scope, filter, attrs) do |entry|
		passwd_last_set = entry.vals('pwdLastSet')
		email_set = entry.vals('mail')
		if passwd_last_set and email_set
			eval_this = entry.vals('pwdLastSet').first.to_i
			result_eval_this = win_to_unix_epoch_v2(eval_this)
			if result_eval_this != 0
				if result_eval_this > 0 then
					users_email = entry.vals('mail').first.to_str
					users_name = entry.vals('cn').first.to_str
					people_emailed << users_name
					people_emailed << "\n"
					email_the_person(users_name,users_email,result_eval_this)
				else
					people_with_no_password_changed_for_a_long_time = 1
					users_email = entry.vals('mail').first.to_s
					users_name = entry.vals('cn').first.to_s
					audit_email_msg << "\n"
					audit_email_msg << users_name
					audit_email_msg << "\t"
					audit_email_msg << result_eval_this.to_s
					audit_email_msg << "\n"
				end
			end
		end
	end
rescue LDAP::ResultError
	conn.perror("search")
	exit
end
conn.perror("search")
conn.unbind
if people_with_no_password_changed_for_a_long_time == 1 then
	audit_email_msg << people_emailed
	email_support(audit_email_msg)
else
	email_support(people_emailed)
end
