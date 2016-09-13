#!/bin/sh
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.

# 09 Sept 2016 Additional fixes to allow script to stop on fatal errors, 
#              and to reinstall over an existing or botched install, 
#              with far less chance of problem. Check for root. 
#              Check for minimum version 6 of CentOS/RedHat.
#              Check for CentOS/RedHat or exit.
#              Patch AvantFax to work right. 
#              Remove http login for avantfax.
#              Patch php.ini error_log to syslog to send cover page.
#              -Chris Coleman, Espace LLC, github.com/EspaceNetworks
# ver. 11.4 fixed numerous quirks to make the script capable of running a second time
# added support for Asterisk 13
# also added support for SHMZ OS with FreePBX Distro and AsteriskNOW
# Ward Mundy & Associates LLC 08-27-2015
# ver. 11.3 updates the script to support CentOS 6.5 et al and current locations
# gvtricks 5.5.2011
# updated HylaFax and AvantFax to latest releases
# updated to support CentOS 6.5 and Scientific Linux 6.5
# Ward Mundy & Associates LLC 04-03-2014
# customized for turnkey install with Incredible PBX 11
# Joe Roper 12.02.2009
# Based on a script written by Phone User
# http://pbxinaflash.com/forum/showthread.php?t=3093
# CHANGELOG 22nd September 2010
# Fixed misnaming of tgz file
# fixed installation directory
# removed test for Incredible
# Install Fax

set -e
set -u

if [ `whoami` != root ]; then
    echo "Please run this script as root or using sudo. Priveleges required to install system packages and update the system to enable fax server."
    exit 1
fi

if [[ ! -e /etc/redhat-release ]]; then
  echo "Sorry. This fax installer requires CentOS/RedHat OS verson 6, 7, or higher."
  exit 1
fi

PBXVERSION=`cat /etc/pbx/.version`
if [ -z $PBXVERSION ]
then
  COLOR=`cat /etc/pbx/.color`
  if [ -z "$COLOR" ]
  then
    echo "Sorry. This installer requires PBX in a Flash 2.0.6.3.1 or later."
    exit 1
  fi
  if [ "$COLOR" != "GREEN" ]
  then
    echo "Sorry. This installer requires PIAF-Green with CentOS 6.3 or 6.4."
    exit 1
  fi
fi

#freepbx must be in running state for this fax installer to work right without error.
set +e
amportal start
set -e

clear
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "This script installs Hylafax/Avantfax/IAXmodem on PIAF-Green systems only!"
echo " "
echo "You first will need to enter the email address for delivery of incoming faxes." 
echo " "
echo "Thereafter, accept ALL the defaults except for entering your local area code. "
#echo " "
#echo "NEVER RUN THIS SCRIPT MORE THAN ONCE ON THE SAME SYSTEM!!!"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
read -p "Press any key to continue or ctrl-C to exit"

clear
echo -n "Enter EMAIL address for delivery of incoming faxes: "
read faxemail
echo "FAX EMail Address: $faxemail"
read -p "If this is correct, press any key to continue or ctrl-C to exit"
echo
echo -n "Enter FAX COUNTRY CODE (USA or Canada enter 1, France enter 33, UK 44, DE 49, etc: "
read faxcountrycode
echo "FAX Country Code: $faxcountrycode"
read -p "If this is correct, press any key to continue or ctrl-C to exit"
echo
echo -n "Enter FAX AREA CODE (shown to destination fax machine for fax reply): "
read faxareacode
echo "FAX AREA CODE: $faxareacode"
read -p "If this is correct, press any key to continue or ctrl-C to exit"
echo
echo -n "Enter FAX NUMBER (normally 7 digits), for example, xxx.xxxx : "
read faxnumber
echo "FULL FAX NUMBER (including country code and area code): +$faxcountrycode.$faxareacode.$faxnumber"
read -p "If this is correct, press any key to continue or ctrl-C to exit"
echo
echo -n "Enter LOCAL IDENTIFIER name, shown to the fax machine yours communicates with: "
read faxlocalidentifier
echo "FAX LOCAL IDENTIFIER: $faxlocalidentifier"
read -p "If this is correct, press any key to continue or ctrl-C to exit"

clear

#Change passw0rd below for your MySQL asteriskuser password if you have changed it from the default.
MYSQLASTERISKUSERPASSWORD=amp109


LOAD_LOC=/usr/src

cd $LOAD_LOC

# install some dependencies
set +e
sed -i 's|enabled=0|enabled=1|' /etc/yum.repos.d/FreePBX.repo
set -e

yum -y install ghostscript ghostscript-fonts sharutils perl-CGI
yum -y install netpbm-progs ImageMagick-devel libungif vixie-cron

#Install Hylafax first so that the directories are in place
processor=`uname -i`
centos=${processor:1:3}

#if [ $centos != 386 ]
#then
# wget -N ftp://ftp.pbone.net/mirror/ftp.sourceforge.net/pub/sourceforge/h/hy/hylafax/hylafax%20CentOS%205%20RPM/hylafax-5.4.3-1.x86_64.rpm
# rpm -Uvh $LOAD_LOC/hylafax-5.4.3-1.x86_64.rpm
#else
# wget -N ftp://ftp.pbone.net/mirror/ftp.sourceforge.net/pub/sourceforge/h/hy/hylafax/hylafax%20CentOS%205%20RPM/hylafax-5.5.0-1.i386.rpm
# rpm -Uvh $LOAD_LOC/hylafax-5.5.0-1.i386.rpm
#fi

echo "Hylafax latest from sourceforge..."
wget -Ohylafax-latest.tar.gz https://sourceforge.net/projects/hylafax/files/latest/download
tar zxvf hylafax-latest.tar.gz
rm -rf hylafax-latest.tar.gz
cd hylafax-*
./configure
make
make install
#will call "faxsetup" later in this install script... see below.

set +e
## updated to hylafax+ to remove future problems if orig HylaFax is someday released for CentOS 6.x
#if [ $centos != 386 ]
#then
# yum -y install hylafax*
 mv /etc/init.d/hylafax+ /etc/init.d/hylafax
#else
# yum -y install hylafax
#fi
chkconfig --add hylafax
chkconfig --add hylafax+
chkconfig hylafax on
chkconfig hylafax+ on
set -e

cd $LOAD_LOC
rm -rf iaxmodem*
#wget -N http://incrediblepbx.com/iaxmodem-1.2.0.tar.gz
wget -Oiaxmodem-latest.tar.gz https://sourceforge.net/projects/iaxmodem/files/latest/download
#wget -N http://garr.dl.sourceforge.net/project/avantfax/avantfax-3.3.3.tgz

#INstall IAXMODEMS 0->3

#cd $LOAD_LOC
tar zxfv iaxmodem-*.tar.gz
rm -rf iaxmodem-*.tar.gz
cd iaxmodem-*
./configure
make

set +e
mkdir /etc/iaxmodem/
mkdir /var/log/iaxmodem
touch /var/log/iaxmodem/iaxmodem.log
service iaxmodem stop
service hylafax stop
service hylafax+ stop
set -e

COUNT=0
while [ $COUNT -lt 4 ]; do
       echo "Number = $COUNT"
       touch /etc/iaxmodem/iaxmodem-cfg.ttyIAX$COUNT
	touch /var/log/iaxmodem/iaxmodem-cfg.ttyIAX$COUNT
       echo "
device /dev/ttyIAX$COUNT
owner uucp:uucp
mode 660
port 457$COUNT
refresh 300
server 127.0.0.1
peername iax-fax$COUNT
cidname FAX SENDER
cidnumber +0000000000$COUNT
codec ulaw
" > /etc/iaxmodem/iaxmodem-cfg.ttyIAX$COUNT

#Setup IAX Registrations
echo "
[iax-fax$COUNT]
type=friend
host=127.0.0.1
port=457$COUNT
context=from-fax
requirecalltoken=no
disallow=all
allow=ulaw
jitterbuffer=no
qualify=yes
deny=0.0.0.0/0.0.0.0
permit=127.0.0.1/255.255.255.0
" >> /etc/asterisk/iax_custom.conf

#Setup Hylafax Modems
cp $LOAD_LOC/iaxmodem-*/config.ttyIAX /var/spool/hylafax/etc/config.ttyIAX$COUNT

echo "
t$COUNT:23:respawn:/usr/sbin/faxgetty ttyIAX$COUNT > /var/log/iaxmodem/iaxmodem.log
" >> /etc/inittab


COUNT=$((COUNT + 1))
done

chown -R uucp:uucp /etc/iaxmodem/
chown uucp:uucp /var/spool/hylafax/etc/config.ttyIAX*


touch /etc/logrotate.d/iaxmodem
echo "
/var/log/iaxmodem/*.log {
    notifempty
    missingok
    postrotate
        /bin/kill -HUP `cat /var/run/iaxmodem.pid` || true
    endscript
}
" > /etc/logrotate.d/iaxmodem


cp iaxmodem /usr/sbin/iaxmodem
cp iaxmodem.init.fedora /etc/rc.d/init.d/iaxmodem
sed -i 's/\/usr\/local\/sbin\/iaxmodem/\/usr\/sbin\/iaxmodem/g'  /etc/rc.d/init.d/iaxmodem
chmod 0755 /etc/rc.d/init.d/iaxmodem
chkconfig --add iaxmodem
chkconfig iaxmodem on
#/etc/init.d/iaxmodem start
service iaxmodem start


#Configure Hylafax
touch /var/spool/hylafax/etc/FaxDispatch
echo "
case \"\$DEVICE\" in
   ttyIAX0) SENDTO=$faxemail; FILETYPE=pdf;; # all faxes received on ttyIAX0
   ttyIAX1) SENDTO=$faxemail; FILETYPE=pdf;; # all faxes received on ttyIAX1
   ttyIAX2) SENDTO=$faxemail; FILETYPE=pdf;; # all faxes received on ttyIAX2
   ttyIAX3) SENDTO=$faxemail; FILETYPE=pdf;; # all faxes received on ttyIAX3
esac
" > /var/spool/hylafax/etc/FaxDispatch

chown uucp:uucp /var/spool/hylafax/etc/FaxDispatch

# Set up Dial Plan

echo "
[custom-fax-iaxmodem]
exten => s,1,Answer
exten => s,n,Wait(1)
exten => s,n,SendDTMF(1)
exten => s,n,Dial(IAX2/iax-fax0/\${EXTEN})
exten => s,n,Dial(IAX2/iax-fax1/\${EXTEN})
exten => s,n,Dial(IAX2/iax-fax2/\${EXTEN})
exten => s,n,Dial(IAX2/iax-fax3/\${EXTEN})
exten => s,n,Busy
exten => s,n,Hangup
" >> /etc/asterisk/extensions_custom.conf

set +e
RESULT=`/usr/bin/mysql -uasteriskuser -p$MYSQLASTERISKUSERPASSWORD <<SQL

use asterisk
INSERT INTO custom_destinations 
	(custom_dest, description, notes)
	VALUES ('custom-fax-iaxmodem,s,1', 'Fax (Hylafax)', '');
quit
SQL`
set -e

clear
echo "ATTN: We now are going to run the Hylafax setup script."
echo "Except for your default area code which must be specified,"
echo "you can safely accept every default by pressing Enter."
read -p "Press the Enter key to begin..."
clear

#wget -N http://incrediblepbx.com/fax/php-pear-Mail-Mime-1.4.0-1.el5.noarch.rpm
#wget -N http://incrediblepbx.com/fax/php-pear-Net-Socket-1.0.10-1.el5.noarch.rpm
#wget -N http://incrediblepbx.com/fax/php-pear-Auth-SASL-1.0.4-1.el5.noarch.rpm
#wget -N http://incrediblepbx.com/fax/php-pear-Net-SMTP-1.4.4-1.el5.noarch.rpm
#wget -N http://incrediblepbx.com/fax/php-pear-Mail-1.1.14-5.el5.1.noarch.rpm
#wget -N http://incrediblepbx.com/fax/php-pear-MDB2-2.4.1-2.el5.noarch.rpm
#wget -N http://incrediblepbx.com/fax/php-pear-MDB2-Driver-mysql-1.4.1-3.el5.noarch.rpm

#rpm -ivh php-pear-Mail-Mime-1.4.0-1.el5.noarch.rpm
#rpm -ivh php-pear-Net-Socket-1.0.10-1.el5.noarch.rpm
#rpm -ivh php-pear-Auth-SASL-1.0.4-1.el5.noarch.rpm
#rpm -ivh php-pear-Net-SMTP-1.4.4-1.el5.noarch.rpm
#rpm -ivh php-pear-Mail-1.1.14-5.el5.1.noarch.rpm
#rpm -ivh php-pear-MDB2-2.4.1-2.el5.noarch.rpm
#rpm -ivh php-pear-MDB2-Driver-mysql-1.4.1-3.el5.noarch.rpm

yum -y install php-pear-Mail-Mime php-pear-Net-Socket php-pear-Auth-SASL 
yum -y install php-pear-Net-SMTP php-pear-Mail php-pear-MDB2 php-pear-MDB2-Driver-mysql

#yum -y update php-pear-Net-Socket
#yum -y update php-pear-Auth-SASL

faxsetup

#Install Avantfax
# No absolute need to drop AvantFax database data. Let Avantfax install over it. Should work OK.
#mysql -uroot -ppassw0rd asterisk -e "DROP DATABASE IF EXISTS avantfax"
cd $LOAD_LOC
#wget -N http://incrediblepbx.com/avantfax-3.3.3.tgz
wget -Oavantfax-latest.tgz https://sourceforge.net/projects/avantfax/files/latest/download
tar zxvf avantfax-latest.tgz
rm -f avantfax-latest.tgz
#cd avantfax-3.3.3
AVANTFAXDIR=`ls -Ad avantfax-*`
cd $AVANTFAXDIR
# Some sed commands to set the preferences
sed -i 's/ROOTMYSQLPWD=/ROOTMYSQLPWD=passw0rd/g' rh-prefs.txt
sed -i 's/apache/asterisk/g' rh-prefs.txt
sed -i 's/fax.mydomain.com/pbx.local/g' rh-prefs.txt
sed -i 's/INSTDIR=\/var\/www\/avantfax/INSTDIR=\/var\/www\/html\/avantfax/g' rh-prefs.txt

sed -i "s|rh-prefs.txt|/usr/src/$AVANTFAXDIR/rh-prefs.txt|g" rh-install.sh

release=$(lsb_release -rs | cut -f1 -d.)
if [[ $release -gt 6 ]]; then
  #IMPORTANT BUG FIX - on centos 7/redhat 7, vixie-cron and mysql-server have been replaced by cronie and mariadb-server !!
  #  So if we don't replace these in the rh-install.sh , then the Avantfax install will totally FAIL!
  #  -Chris Coleman, EspaceNetworks.com , github.com/EspaceNetworks
  sed -i "s|vixie-cron|cronie|g" rh-install.sh
  sed -i "s|mysql-server|mariadb-server|g" rh-install.sh
fi

./rh-install.sh

rm -rf /etc/httpd/conf.d/avantfax.conf


# Add a menu item to kennonsoft interface
#copy in the picture
cd $LOAD_LOC
set +e
wget -N http://incrediblepbx.com/ico_fax.png
mv $LOAD_LOC/ico_fax.png /var/www/html/welcome/ico_fax.png
set -e
sed -i '/asteridex/ i\1,Fax,./avantfax,Avantfax,ico_fax.png' /var/www/html/welcome/.htindex.cfg

chown -R asterisk:asterisk /var/lib/php/session/

cd /etc/pbx/httpdconf
wget -N http://incrediblepbx.com/reminders.conf
#cp reminders.conf avantfax.conf
#sed -i 's|reminders|avantfax|g' avantfax.conf
chmod 744 *
# Remove it from here in case it was previously installed here. This bug will prevent login to AvantFax.
rm -rf avantfax.conf

#Fix bug: Fail to send coverpage
sed -i "s|#error_log = syslog|error_log = syslog|g" /etc/php.ini
sed -i "s|;error_log = syslog|error_log = syslog|g" /etc/php.ini


service httpd restart

asterisk -rx "module reload"
#amportal restart

mysql -uroot -ppassw0rd avantfax <<EOF
use avantfax;
update UserAccount set username="admin" where uid=1;
update UserAccount set can_del=1 where uid=1;
update UserAccount set wasreset=1 where uid=1;
update UserAccount set acc_enabled=1 where uid=1;
update UserAccount set email="$faxemail" where uid=1;
update Modems set contact="$faxemail" where devid>0;
EOF

echo "
[from-fax]
exten => _x.,1,Dial(local/\${EXTEN}@from-internal)
exten => _x.,n,Hangup
" >> /etc/asterisk/extensions_custom.conf

sed -i 's|NVfaxdetect(5)|Goto(custom-fax-iaxmodem,s,1)|g' /etc/asterisk/extensions_custom.conf

asterisk -rx "dialplan reload"

cd $LOAD_LOC
wget -N http://incrediblepbx.com/hylafax_mod-1.8.2.wbm.gz

cd /usr/share/ghostscript/?.??/Resource/Init
mv Fontmap.GS Fontmap.GS.orig
wget -N http://incrediblepbx.com/Fontmap.GS


write_ttyiax() {
  echo "
JobReqNoAnswer:  180
JobReqNoCarrier: 180
#ModemRate:      14400
" >> /var/spool/hylafax/etc/config.ttyIAX$1
sed -i "s/CountryCode:\t\t1/CountryCode:\t\t$faxcountrycode/g" /var/spool/hylafax/etc/config.ttyIAX$1
sed -i "s/AreaCode:\t\t800/AreaCode:\t\t$faxareacode/g" /var/spool/hylafax/etc/config.ttyIAX$1
sed -i "s/FAXNumber:\t\t+1.800.555.1212/FAXNumber:\t\t+$faxcountrycode.$faxareacode.$faxnumber/g" /var/spool/hylafax/etc/config.ttyIAX$1
sed -i "s/LocalIdentifier:\t\"IAXmodem\"/LocalIdentifier:\t\"$faxlocalidentifier\"/g" /var/spool/hylafax/etc/config.ttyIAX$1
}

for i in `seq 0 3`;
do
   write_ttyiax $i
done


sed -i "s/a4/letter/" /var/www/html/avantfax/includes/local_config.php

sed -i "s/root@localhost/$faxemail/" /var/www/html/avantfax/includes/local_config.php
sed -i "s/root@localhost/$faxemail/" /var/www/html/avantfax/includes/config.php

chmod 1777 /tmp
chmod 555 /

# needed for WebMin module
perl -MCPAN -e 'install CGI'

sed -i '/faxgetty/d' /etc/rc.d/rc.local
echo "faxgetty -D ttyIAX0" >> /etc/rc.d/rc.local
echo "faxgetty -D ttyIAX1" >> /etc/rc.d/rc.local
echo "faxgetty -D ttyIAX2" >> /etc/rc.d/rc.local
echo "faxgetty -D ttyIAX3" >> /etc/rc.d/rc.local

# needed for /etc/cron.hourly/hylafax+
cd /etc/sysconfig
wget -N http://incrediblepbx.com/hylafax+
chmod 755 hylafax+

sed -i '/exit 0/d' /etc/rc.d/rc.local
echo "exit 0" >> /etc/rc.d/rc.local

# Add Josh North Avantfax module for the GUI
cd /var/www/html/admin/modules
rm -rf avantfax
git clone https://github.com/joshnorth/FreePBX-AvantFAX avantfax
chown -R asterisk:asterisk avantfax
amportal a ma install avantfax
amportal a r

mysql -u root -ppassw0rd -e "UPDATE avantfax.UserAccount SET  username =  'admin' WHERE  avantfax.UserAccount.uid =1;"

cd /var/www/html/avantfax/includes
wget -N http://incrediblepbx.com/avantfax-config.tar.gz
tar zxvf avantfax-config.tar.gz

set +e
sed -i 's|enabled=1|enabled=0|' /etc/yum.repos.d/FreePBX.repo
set -e
gui-fix

echo "minregexpire=60" > /etc/asterisk/iax_registrations_custom.conf
echo "maxregexpire=600" >> /etc/asterisk/iax_registrations_custom.conf
echo "defaultexpire=300" >> /etc/asterisk/iax_registrations_custom.conf
chown asterisk:asterisk /etc/asterisk/iax_registrations_custom.conf

touch /var/www/html/admin/modules/avantfax/module.sig
chmod 775 /var/www/html/admin/modules/avantfax/module.sig
chown asterisk:asterisk /var/www/html/admin/modules/avantfax/module.sig

cd /root


clear
echo " "
echo " "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Incredible FAX with IAXModem/Hylafax/Avantfax installation complete"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " "
echo "Avantfax is password-protected. First, reset password: /root/avantfax-pw-change"
echo "Then login to AvantFax from either GUI with username: admin and new password."
echo "Point browser to http://serverIPaddress/avantfax or use Incredible Admin GUI."
echo " "
echo "Fax detection is NOT supported. Incoming fax support requires a dedicated DID! "
echo "See this post if you have trouble sending faxes: http://nerd.bz/10MecwG"
echo " "
echo "Point a DID to new Custom Destination FAX (Hylafax): custom-fax-iaxmodem,s,1"
echo "Outbound faxing will go out via the normal trunks as configured."
echo " "
echo "A Hylafax webmin module has been placed in $LOAD_LOC/hylafax_mod-1.8.2.wbm.gz"
echo "This is added via Webmin | Webmin Configuration | Webmin Modules | From Local File"
echo " "
echo "For a complete tutorial and video demo, visit: http://nerdvittles.com/?p=738"
echo " "
echo "You must Reboot now to bring Incredible Fax online."
echo " "
read -p "Press any key to reboot or ctrl-C to exit"
reboot
