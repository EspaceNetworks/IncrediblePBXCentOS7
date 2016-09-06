#!/bin/bash
#
#
hn=`hostname`
sed -i 's|dest=you@example.com|dest=root|' /etc/fail2ban/jail.conf
#sed -i "s|fail2ban@|sender=fail2ban@$hn|" /etc/fail2ban/jail.conf
sed -i "s|sender=fail2ban@example.com|sender=fail2ban@$hn|" /etc/fail2ban/jail.conf
sed -i "s|sender=asterisk@fail2ban.local|sender=asterisk@$hn|" /etc/fail2ban/jail.conf
