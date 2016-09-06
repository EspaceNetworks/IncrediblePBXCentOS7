#!/bin/bash
TEST=`sed '578q;d' /etc/fail2ban/jail.conf`
if [ "$TEST" = "" ]; then
 echo Applying Fail2Ban asterisk-tcp patch
 THELINE=`grep -n asterisk-tcp] /etc/fail2ban/jail.conf | cut -f 1 -d ":"`
 THELINE=$((THELINE+1))
 sed -i "$THELINE s:^:enabled = yes:" /etc/fail2ban/jail.conf
 THELINE=$((THELINE+1))d
 sed -i "$THELINE" /etc/fail2ban/jail.conf
 service fail2ban restart
 iptables -nL
else
 echo No asterisk-tcp patch required for Fail2Ban
fi
