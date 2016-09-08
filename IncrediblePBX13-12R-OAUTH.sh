#!/bin/bash

#    Incredible PBX Copyright (C) 2005-2016, Ward Mundy & Associates LLC.
#    This program installs Asterisk, Incredible PBX and GUI on Cent OS. 
#    All programs copyrighted and licensed by their respective companies.
#
#    Portions Copyright (C) 1999-2016,  Digium, Inc.
#    Portions Copyright (C) 2005-2016,  Sangoma Technologies, Inc.
#    Portions Copyright (C) 2005-2016,  Ward Mundy & Associates LLC
#    Portions Copyright (C) 2014-2016,  Eric Teeter teetere@charter.net
#    Portions Copyright (C) 2016,       Chris Coleman, ESPACE LLC chris@espacenetworks.com
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#    GPL2 license file can be found at /root/COPYING after installation.
#

clear
set -o nounset
#set -o errexit

if [ -e "/etc/pbx/.incredible" ]; then
 echo "Incredible PBX is already installed."
 exit 1
fi

#These are the varables required to make the install script work
#Do NOT change them
version="13-12.3"

if [ ! -f /root/DMI ]; then
clear
echo ".-.                          .-. _ .-.   .-.            .---. .---. .-..-."
echo ": :                          : ::_;: :   : :  v$version  : .; :: .; :: \`' :"
echo ": :,-.,-. .--. .--.  .--.  .-' :.-.: \`-. : :   .--.     :  _.':   .' \`  ' "
#echo $version
echo ": :: ,. :'  ..': ..'' '_.'' .; :: :' .; :: :_ ' '_.'    : :   : .; :.'  \`."
echo ":_;:_;:_;\`.__.':_;  \`.__.'\`.__.':_;\`.__.'\`.__;\`.__.'    :_;   :___.':_;:_;"
echo "Copyright (c) 2005-2016, Ward Mundy & Associates LLC. All rights reserved."
echo " "
echo "WARNING: This install will erase ALL existing GUI configurations!"
echo " "
echo "BY USING THE INCREDIBLE PBX, YOU AGREE TO ASSUME ALL RESPONSIBILITY"
echo "FOR USE OF THE PROGRAMS INCLUDED IN THIS INSTALLATION. NO WARRANTIES"
echo "EXPRESS OR IMPLIED INCLUDING MERCHANTABILITY AND FITNESS FOR PARTICULAR"
echo "USE ARE PROVIDED. YOU ASSUME ALL RISKS KNOWN AND UNKNOWN AND AGREE TO"
echo "HOLD WARD MUNDY, WARD MUNDY & ASSOCIATES LLC, NERD VITTLES, AND THE PBX"
echo "IN A FLASH DEVELOPMENT TEAM HARMLESS FROM ANY AND ALL LOSS OR DAMAGE"
echo "WHICH RESULTS FROM YOUR USE OF THIS SOFTWARE. AS CONFIGURED, THIS"
echo "SOFTWARE CANNOT BE USED TO MAKE 911 CALLS, AND YOU AGREE TO PROVIDE"
echo "AN ALTERNATE PHONE CAPABLE OF MAKING EMERGENCY CALLS. IF ANY OF THESE TERMS"
echo "AND CONDITIONS ARE RULED TO BE UNENFORCEABLE, YOU AGREE TO ACCEPT ONE"
echo "DOLLAR IN U.S. CURRENCY AS COMPENSATORY AND PUNITIVE LIQUIDATED DAMAGES"
echo "FOR ANY AND ALL CLAIMS YOU AND ANY USERS OF THIS SOFTWARE MIGHT HAVE."
echo " "

echo "If you do not agree with these terms and conditions of use, press Ctrl-C now."
read -p "Otherwise, press Enter to proceed at your own risk..."
fi

clear
echo ".-.                          .-. _ .-.   .-.            .---. .---. .-..-."
echo ": :                          : ::_;: :   : :  v$version  : .; :: .; :: \`' :"
echo ": :,-.,-. .--. .--.  .--.  .-' :.-.: \`-. : :   .--.     :  _.':   .' \`  ' "
#echo $version
echo ": :: ,. :'  ..': ..'' '_.'' .; :: :' .; :: :_ ' '_.'    : :   : .; :.'  \`."
echo ":_;:_;:_;\`.__.':_;  \`.__.'\`.__.':_;\`.__.'\`.__;\`.__.'    :_;   :___.':_;:_;"
echo "Copyright (c) 2005-2016, Ward Mundy & Associates LLC. All rights reserved."
echo " "
echo "Installing The Incredible PBX. Please wait. This installer runs unattended."
echo "Consider a modest donation to Nerd Vittles while waiting. Return in 30 minutes."
echo "Do NOT press any keys while the installation is underway. Be patient!"
echo " "


# First is the FreePBX-compatible version number
export VER_FREEPBX=12.0

# Second is the Asterisk Database Password
export ASTERISK_DB_PW=amp109

# Third is the MySQL Admin password. Must be the same as when you install MySQL!!
export ADMIN_PASS=passw0rd

# set the PATH for VM install protection
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
export PATH

#centos=x86_64
testarch=`uname -m`
if [[ "x86_64" = "$testarch" ]]; then
 arch64=true
else
 arch64=false
fi

if [[ "i686" = "$testarch" ]]; then
 arch32=true
else
 arch32=false
 if [[ "i386" = "$testarch" ]]; then
 arch32=true
fi

if [ ! -e /etc/redhat-release ]; then
 echo "Failed to detect CentOS or a RedHat compatible OS distro. Exiting..."
 exit 1
else
 read -p "Detected CentOS or RedHat compatible OS disto. Enter to continue or Ctrl-C to exit."
fi


#testversion=`cat /etc/redhat-release | grep " 6."`
release=$(lsb_release -rs | cut -f1 -d.)
#if [[ -z $testversion ]]; then
# release="7"
#else
# release="6"
#fi
# lsb_release returns "7.2.9483".
# release will equal 6 or 7 or whatever the major version is.

if [ $release -lt "6" ]; then 
  echo "OS major version requirement not met: Require CentOS/RedHat 6.x or 7.x (or above). Exiting..."
  exit 1
fi

set +e
setenforce 0
set -e

if [ ! -f /root/DMI ]; then
# patch to fix the system time once and for all
echo "Synchronizing your clocks and existing file stamps..."
echo "You may safely ignore the errors. They are normal."
echo "System clock:"
date
echo "Hardware clock:"
hwclock --show
hwclock --systohc
cd /
touch currtime
find . -xdev -type d -cnewer /currtime -exec touch {} \;
echo "Done."
echo " "
fi

# here is the BASH GOTO trick
#if false; then

# getting CentOS7 up to speed
yum -y update
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
yum -y install deltarpm yum-presto
yum -y install net-tools wget nano kernel-devel kernel-headers
mkdir -p /etc/pbx

# protect the updated TM3 scripts
cd /root
chattr +i add-*
chattr +i del-*

echo "-->  Installing packages needed to work with Asterisk"
echo "---> first 8"
yum -y --skip-broken install glibc* yum-fastestmirror opens* anaconda* poppler-utils perl-Digest-SHA1 perl-Crypt-SSLeay xorg-x11-drv-qxl
echo "---> next 13"
yum -y --skip-broken install dialog binutils* mc sqlite sqlite-devel libstdc++-devel tzdata SDL* syslog-ng syslog-ng-libdbi texinfo uuid-devel libuuid-devel
echo "--> next 4"
yum -y --skip-broken install cairo* atk* freetds freetds-devel
# can't find lame
#yum -y install lame lame-devel
# can't find fail2ban
#yum -y install fail2ban
echo "--> redhat-lsb-core"
yum -y install redhat-lsb-core
echo "--> groupinstall 25 groups!"
echo "--> additional-devel"
yum -y --skip-broken groupinstall additional-devel 
echo "--> base"
yum -y groupinstall base 
echo "--> cifs-file-server"
yum -y groupinstall cifs-file-server 
echo "--> compat-libraries"
yum -y groupinstall compat-libraries
echo "--> console-internet"
yum -y groupinstall console-internet
echo "--> core"
yum -y --skip-broken groupinstall core
yum -y groupinstall debugging
yum -y groupinstall development
yum -y groupinstall mail-server
yum -y groupinstall ftp-server
yum -y --skip-broken groupinstall hardware-monitoring
yum -y --skip-broken groupinstall java-platform
yum -y --skip-broken groupinstall legacy-unix
yum -y --skip-broken groupinstall mysql
yum -y --skip-broken groupinstall network-file-system-client
yum -y --skip-broken groupinstall network-tools 
yum -y --skip-broken groupinstall php 
yum -y --skip-broken groupinstall performance perl-runtime security-tools server-platform
yum -y --skip-broken groupinstall  server-policy system-management system-admin-tools web-server
yum -y --skip-broken install gnutls-devel gnutls-utils mysql* mariadb* libtool-ltdl-devel lua-devel libsrtp-devel speex* php-mysql php-mbstring perl-JSON php-process
yum -y --skip-broken install sox
yum -y --skip-broken install perl-LWP-Protocol-https
echo "--> Done installing packages neede to work with asterisk"


echo "--> mariadb and mysql"
if [[ "$release" = "7" ]]; then
 set +e
 ln -s /usr/lib/systemd/system/mariadb.service /usr/lib/systemd/system/mysqld.service
 set -e
 echo "#\!/bin/bash" > /etc/init.d/mysqld
 sed -i 's|\\||' /etc/init.d/mysqld
 echo "service mariadb \$1" >> /etc/init.d/mysqld
 chmod +x /etc/init.d/mysqld
 chkconfig --levels 235 mariadb on
else
 chkconfig --levels 235 mysqld on
fi
echo "--> done mariadb and mysql"

echo "--> spandsp"
# http://rpmfind.net/linux/rpm2html/search.php?query=spandsp
rm -rf spandsp*
TEST=`rpm -qa spandsp`
if [[ ! "$TEST" ]]; then
if $arch64; then
 wget ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/dkdegroot:/asterisk/CentOS_CentOS-6/x86_64/spandsp-0.0.6-35.1.x86_64.rpm
 wget ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/dkdegroot:/asterisk/CentOS_CentOS-6/x86_64/spandsp-devel-0.0.6-35.1.x86_64.rpm
else
 wget ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/dkdegroot:/asterisk/CentOS_CentOS-6/i686/spandsp-0.0.6-35.1.i686.rpm
 wget ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/dkdegroot:/asterisk/CentOS_CentOS-6/i686/spandsp-devel-0.0.6-35.1.i686.rpm
fi
rpm -ivh spandsp-*.rpm
rm -rf spandsp-*.rpm
wait
fi

# Installing RPM Forge repo
if [[ "$release" = "7" ]]; then
 if [[ "$arch64" = "true" ]]; then
  wget http://repository.it4i.cz/mirrors/repoforge/redhat/el7/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
 else
  wget http://repository.it4i.cz/mirrors/repoforge/redhat/el6/en/i386/rpmforge/RPMS/rpmforge-release-0.5.3-1.el6.rf.i686.rpm
 fi
else
 if [[ "$arch64" = "true" ]]; then
  wget http://repository.it4i.cz/mirrors/repoforge/redhat/el6/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
 else
  wget http://repository.it4i.cz/mirrors/repoforge/redhat/el6/en/i386/rpmforge/RPMS/rpmforge-release-0.5.3-1.el6.rf.i686.rpm
 fi
fi
set +e
rpm -Uvh rpmforge-release-*
rm -f rpmforge-release-*
set -e

#install yumlist AFTER installing the epel repo
#cd /root
#yum -y install $(cat yumlist.txt)
##rm -f yumlist.txt
##touch yumlist.txt

set +e

# get the epel repo
rm -f epel-release-latest-*.noarch.rpm*
if [[ "$release" = "6" ]]; then
 wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
 rpm -Uvh epel-release-latest-6.noarch.rpm
 rm -f epel-release-latest-6.noarch.rpm
fi
if [[ "$release" = "7" ]]; then
 wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
 rpm -Uvh epel-release-latest-7.noarch.rpm
 rm -f epel-release-latest-7.noarch.rpm
 if [[ "$arch32" = "true" ]]; then
  sed -i 's|/epel/7/$basearch|/epel/7/x86_64|' /etc/yum.repos.d/epel.repo
  sed -i 's|&arch=$basearch|&arch=x86_64|' /etc/yum.repos.d/epel.repo
 fi
fi

# install pip for python packages.
yum install -y python-pip
pip install --upgrade pip
pip install --upgrade simplejson
pip install --upgrade setuptools

set +e

# NOW that repos are installed, install the yumlist
cd /root
yum -y --skip-broken install $(cat yumlist.txt)
#yum -y install freetds freetds-devel

# set up NTP
/usr/sbin/ntpdate -su pool.ntp.org

# check for Proxmox here and reboot
dmi=`dmidecode | grep QEMU`
if [ ! -z "$dmi" ];
then
 if [ ! -f /root/DMI ]; then
  /bin/touch /root/DMI
  clear
  echo "On this platform we need to reboot before we continue."
  echo "One moment please..."
  sleep 5
  /bin/sed -i 's|rhgb quiet||' /boot/grub/grub.conf
  /bin/echo "/tmp/firstboot" >> /etc/rc.d/rc.local
  /bin/sed -i '/incrediblepbx13/d' /tmp/firstboot
  reboot
 fi
fi


set -e

cd /usr/src
rm -f iksemel-*.tar.gz*
wget --no-check-certificate https://iksemel.googlecode.com/files/iksemel-1.4.tar.gz
tar zxvf iksemel-1.4.tar.gz
rm -f iksemel-*.tar.gz*
cd iksemel*
./configure --prefix=/usr --with-libgnutls-prefix=/usr
make
make check
make install
echo "/usr/local/lib" > /etc/ld.so.conf.d/iksemel.conf 
ldconfig

set +e

#setup database
echo "----> Setup database"
pear channel-update pear.php.net
pear install -Z db-1.7.14
wait

#pear Console_Getopt from FreePBX 13 wiki.
echo "--> Pear legacy"
pear install Console_Getopt
wait

#install Asterisk packages
echo "----> Install Asterisk packages"

# get the kernel source linkage correct. Thanks to?
# http://linuxmoz.com/asterisk-you-do-not-appear-to-have-the-sources-for-kernel-installed/
cd /lib/modules/`uname -r`
if $arch64; then
 ln -fs /usr/src/kernels/`ls -d /usr/src/kernels/*.x86_64 | cut -f 5 -d "/"` build
else
 ln -fs /usr/src/kernels/`ls -d /usr/src/kernels/*.i686 | cut -f 5 -d "/"` build
fi

cd /usr/src
set +e
rm -r dahdi-linux-complete*
rm -r libpri-*
rm -r asterisk-*
rm -r pjproject-*
rm -r srtp*

set -e

#from source by Billy Chia
cd /usr/src
wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz
#wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-2.10.2+2.10.2.tar.gz
wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz
#wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13.7.2.tar.gz
#wget https://iksemel.googlecode.com/files/iksemel-1.4.tar.gz
wget http://www.pjsip.org/release/2.5.5/pjproject-2.5.5.tar.bz2

tar zxvf dahdi-linux-complete-*.tar.gz
tar zxvf libpri-*.tar.gz
tar zxvf asterisk-*.tar.gz
#tar zxvf iksemel-*.tar.gz
tar jxvf pjproject-*.tar.bz2

mv *.tar.gz /tmp
mv *.tar.bz2 /tmp

set +e
#adduser asterisk -M -c "Asterisk User"
adduser asterisk -M -d /var/lib/asterisk -s /sbin/nologin -c "Asterisk User"
set -e

#cd /usr/src/iksemel-*
#./configure
#make && make install

cd /usr/src/dahdi-linux-complete*
make all && make install && make config
#read -p "PLEASE LOOK FOR ERRORS"

cd /usr/src/libpri*
make && make install
#read -p "PLEASE LOOK FOR ERRORS"
cd ..
rm -r libpri*

set +e
cd /usr/src
#wget http://srtp.sourceforge.net/srtp-1.4.2.tgz
wget -Osrtp-2.0.0.tgz https://github.com/cisco/libsrtp/archive/v2.0.0.tar.gz
tar zxvf srtp-*.tgz
rm -f srtp-*.tgz
cd srtp*
./configure CFLAGS=-fPIC
make && make runtest && make uninstall && make install
#read -p "PLEASE LOOK FOR ERRORS"
cd ..
rm -r srtp*
set -e

cd /usr/src/pjproject*
if $arch64; then
 CFLAGS='-DPJ_HAS_IPV6=1' ./configure --prefix=/usr --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr --libdir=/usr/lib64
else
 CFLAGS='-DPJ_HAS_IPV6=1' ./configure --prefix=/usr --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr --libdir=/usr/lib
fi
make dep
make && make install
#read -p "PLEASE LOOK FOR ERRORS"

#cd /usr/src
#git clone https://github.com/akheron/jansson.git
#cd /usr/src/jansson
#autoreconf -i
#./configure --libdir=/usr/lib64
#make && make install

cd /usr/src
TEST=`rpm -qa jansson`
if [[ ! "$TEST" ]]; then
if $arch64; then
 wget ftp://ftp.pbone.net/mirror/download.fedora.redhat.com/pub/fedora/epel/6/x86_64/jansson-2.6-1.el6.x86_64.rpm
 wget ftp://ftp.pbone.net/mirror/download.fedora.redhat.com/pub/fedora/epel/6/x86_64/jansson-devel-2.6-1.el6.x86_64.rpm
else
 wget ftp://ftp.pbone.net/mirror/download.fedora.redhat.com/pub/fedora/epel/6/i386/jansson-2.6-1.el6.i686.rpm
 wget ftp://ftp.pbone.net/mirror/download.fedora.redhat.com/pub/fedora/epel/6/i386/jansson-devel-2.6-1.el6.i686.rpm
fi
rpm -Uvh jansson-*
rpm -Uvh jansson-devel*
#rm jansson-*.rpm
fi
#read -p "PLEASE LOOK FOR ERRORS"

set +e
echo "--> build asterisk..."
cd /usr/src/asterisk-*
contrib/scripts/install_prereq install
contrib/scripts/get_mp3_source.sh 
wget http://incrediblepbx.com/res_xmpp-13.tar.gz
tar zxvf res_xmpp-13.tar.gz
#read -p "PLEASE LOOK FOR ERRORS"
set -e

make distclean
autoconf
./bootstrap.sh
#read -p "PLEASE LOOK FOR ERRORS"

wget http://incrediblepbx.com/menuselect-incredible13.tar.gz
tar zxvf menuselect-incredible13.tar.gz*
rm -f menuselect-incredible*.tar.gz*
#read -p "PLEASE LOOK FOR ERRORS"

if $arch64; then
 ./configure --libdir=/usr/lib64
else
 ./configure --libdir=/usr/lib
fi

echo "--> make menuselect"
#make menuselect
expect -c 'set timeout 10;spawn make menuselect;expect "Save";send "\t\t\r";interact'
make menuselect.makeopts
menuselect/menuselect --enable-category  MENUSELECT_ADDONS menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-EN-GSM --enable MOH-OPSOUND-WAV --enable EXTRA-SOUNDS-EN-GSM --enable cdr_mysql menuselect.makeopts
menuselect/menuselect --disable app_mysql --disable app_setcallerid --disable func_audiohookinherit --disable res_fax_spandsp menuselect.makeopts
#read -p "PLEASE LOOK FOR ERRORS"

#expect -c 'set timeout 60;spawn make menuselect;expect "Save";send "\t\t\r";interact'
#make menuselect

echo "--> make make install make config make samples"
make && make install && make config && make samples
ldconfig
#read -p "PELASE LOOK FOR ERRORS"

echo "--> add Asterisk-Flite (text to speech) support"
#Add Flite support
#apt-get install libsdl1.2-dev libflite1 flite1-dev flite -y
cd /usr/src
# git clone https://github.com/zaf/Asterisk-Flite.git
#wget --no-check-certificate https://github.com/downloads/zaf/Asterisk-Flite/Asterisk-Flite-2.2-rc1-flite1.3.tar.gz
set +e
#Remove old folders and tarballs leftover.
rm -rf *Asterisk-Flite-*
set -e
if [[ "$release" = "7" ]]; then
 #wget http://incrediblepbx.com/Asterisk-Flite-2.2-rc1-flite1.3.tar.gz
 #tar zxvf Asterisk-Flite*
 #cd Asterisk-Flite*
 echo " "
else
 yum -y --skip-broken install flite flite-devel
 #sed -i 's|enabled=1|enabled=0|' /etc/yum.repos.d/epel.repo
 #wget http://incrediblepbx.com/Asterisk-Flite-2.2-rc1-flite1.3.tar.gz
 #tar zxvf Asterisk-Flite*
 #cd Asterisk-Flite*
fi
wget -OAsterisk-Flite-current.tar.gz http://github.com/zaf/Asterisk-Flite/tarball/flite-1.3
tar zxvf Asterisk-Flite-current.tar.gz
# which extracts it into new folder zaf-Asterisk-Flite-(random number)
rm -f Asterisk-Flite-current.tar.gz
cd *Asterisk-Flite-*
ldconfig
make
make install
cd /usr/src
rm -rf *Asterisk-Flite-*
set -e
#read -p "PLEASE LOOK FOR ERRORS"

echo "--> add higher quality (g722 HD Voice) sound files"
cd /var/lib/asterisk/sounds
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-en-wav-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-wav-current.tar.gz
# Narrowband Audio G.711 8 kHz voice at 64 kbit/sec
tar xvf asterisk-core-sounds-en-wav-current.tar.gz
#rm -f asterisk-core-sounds-en-wav-current.tar.gz
tar xfz asterisk-extra-sounds-en-wav-current.tar.gz
#rm -f asterisk-extra-sounds-en-wav-current.tar.gz
# Wideband Audio HD Voice G.722 16 kHz at 64 kbit/sec
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-en-g722-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-g722-current.tar.gz
tar xfz asterisk-extra-sounds-en-g722-current.tar.gz
#rm -f asterisk-extra-sounds-en-g722-current.tar.gz
tar xfz asterisk-core-sounds-en-g722-current.tar.gz
#rm -f asterisk-core-sounds-en-g722-current.tar.gz

echo "--> add mp3 support"
#Add MP3 support. upgrade from 1.16.0 to 1.23.6.
cd /usr/src
rm -rf mpg123.tar.bz2*
wget -Ompg123.tar.bz2 http://sourceforge.net/projects/mpg123/files/mpg123/1.23.6/mpg123-1.23.6.tar.bz2/download
#mv download mpg123.tar.bz2
tar -xjvf mpg123.tar.bz2
rm -f mpg123.tar.bz2*
cd mpg123*/
./configure && make && make install && ldconfig
set +e
# maybe link already exists, if so, it's ok, don't fail, they probably already ran this script before.
ln -s /usr/local/bin/mpg123 /usr/bin/mpg123
set -e
#read -p "PLEASE LOOK FOR ERRORS"

# Reconfigure Apache for Asterisk
sed -i "s/User apache/User asterisk/" /etc/httpd/conf/httpd.conf
sed -i "s/Group apache/Group asterisk/" /etc/httpd/conf/httpd.conf

if [[ "$release" = "7" ]]; then
 #/etc/init.d/dahdi start
 #/etc/init.d/asterisk start
 service dahdi start
 service asterisk start
else
 service dahdi start
 service asterisk start
 sed -i 's|module.so|mcrypt.so|' /etc/php.d/mcrypt.ini
fi
#read -p "PLEASE LOOK FOR ERRORS"

# if these already exist, don't fail, it's ok.
set +e
#Now create the Asterisk user and set ownership permissions.
echo "----> Create the Asterisk user and set ownership permissions and modify Apache"
#adduser asterisk -M -d /var/lib/asterisk -s /sbin/nologin -c "Asterisk User"
chown asterisk. /var/run/asterisk
chown -R asterisk. /etc/asterisk
chown -R asterisk. /var/{lib,log,spool}/asterisk
chown -R asterisk. /usr/lib64/asterisk
chown -R asterisk. /usr/lib/asterisk
mkdir /var/www/html
chown -R asterisk. /var/www/

#A few small modifications to Apache.
sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php.ini
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf_orig
sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/httpd/conf/httpd.conf
service httpd restart

# Set MyISAM as default MySQL storage so we can make quick backups
sed -i '/\[mysqld\]/a default-storage-engine=MyISAM' /etc/my.cnf
sed -i '/\[mysqld\]/a innodb=OFF' /etc/my.cnf
service mysqld restart


#fi
#echo "Here is the ending GOTO label"

# First is the FreePBX-compatible version number
export VER_FREEPBX=12.0

# Second is the Asterisk Database Password
export ASTERISK_DB_PW=amp109

# Third is the MySQL Admin password. Must be the same as when you install MySQL!!
export ADMIN_PASS=passw0rd


#Download and extract base install of GUI 
echo "----> Download and extract base install for GUI..."

service asterisk stop

cd /usr/src
#wget http://incrediblepbx.com/freepbx-12.0.70.tgz
rm -rf freepbx
wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-12.0-latest.tgz
tar vxfz freepbx-*.tgz
rm -f freepbx-*.tgz*

chown asterisk. /var/run/asterisk
chown -R asterisk. /etc/asterisk
chown -R asterisk. /var/{lib,log,spool}/asterisk
chown -R asterisk. /usr/lib/asterisk
chown -R asterisk. /usr/lib64/asterisk
rm -rf /var/www/html

cd /usr/src/freepbx
export ASTERISK_DB_PW=amp109
mysqladmin -u root create asterisk 
mysqladmin -u root create asteriskcdrdb

mysql -u root -e "GRANT ALL PRIVILEGES ON asterisk.* TO asteriskuser@localhost IDENTIFIED BY '${ASTERISK_DB_PW}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON asteriskcdrdb.* TO asteriskuser@localhost IDENTIFIED BY '${ASTERISK_DB_PW}';"
mysql -u root -e "flush privileges;"

rm -f /etc/asterisk/enum.conf
rm -f /etc/asterisk/cdr_mysql.conf
rm -f /etc/asterisk/phone.conf
rm -f /etc/asterisk/manager.conf
rm -f /etc/asterisk/meetme.conf
rm -f /etc/asterisk/indications.conf
rm -f /etc/asterisk/queues.conf
rm -f /etc/asterisk/musiconhold.conf
rm -f /etc/asterisk/modules.conf

cd /usr/src/freepbx
./start_asterisk start
./install_amp --installdb --username=asteriskuser --password=amp109 --asteriskuser=asteriskuser --asteriskpass=amp109 --freepbxip=127.0.0.1 --dbname=asterisk --dbhost=localhost --webroot=/var/www/html --force-overwrite --scripted
#./install_amp --installdb --username=asteriskuser --password=${ASTERISK_DB_PW}
amportal chown

#amportal a ma installall

amportal a ma update framework

amportal a s
amportal a reload
amportal a ma refreshsignatures
amportal chown

chown -R asterisk. /var/www/

ln -s /var/lib/asterisk/moh /var/lib/asterisk/mohmp3

rm -rf /var/lib/asterisk/mohmp3/moh
rm -rf /var/lib/asterisk/moh/moh

amportal a ma uninstall sipstation
amportal a ma uninstall sms
amportal a ma uninstall isymphony
amportal a ma uninstall cxpanel
amportal a ma uninstall webrtc
amportal a ma uninstall ucp
amportal a ma uninstall customappsreg

rm -rf /var/www/html/admin/modules/sipstation
rm -rf /var/www/html/admin/modules/sms
rm -rf /var/www/html/admin/modules/isymphony
rm -rf /var/www/html/admin/modules/cxpanel
rm -rf /var/www/html/admin/modules/webrtc
rm -rf /var/www/html/admin/modules/ucp

service mysqld restart
service httpd restart
amportal kill
amportal start
amportal a s
amportal a r
service iptables stop

# Now it's time to set the MySQL root password
mysqladmin -u root password 'passw0rd'

# Installing Incredible PBX GUI
cd /
amportal kill
service asterisk stop
service httpd stop
service mysqld stop

# FIX htaccess and MaxClient settings in Apache setup for proper GUI operation
sed -i 's|AllowOverride None|AllowOverride All|' /etc/httpd/conf/httpd.conf
sed -i 's|256|5|' /etc/httpd/conf/httpd.conf

echo "Ready to load Incredible PBX GUI image now..."

mv /root/gui-fix /usr/local/sbin/gui-fix

chattr +i /etc/amportal.conf
chattr +i /etc/my.cnf
chattr +i /usr/local/sbin/*

wget http://incrediblepbx.com/incredible13-12-image.tar.gz
tar zxvf incredible13-12-image.tar.gz
rm -f incredible13-12-image.tar.gz*

chown -R asterisk:asterisk /var/www/html/*
chattr -i /usr/local/sbin/amportal
chattr -i /etc/amportal.conf
chattr -i /etc/my.cnf
rm -f /usr/local/sbin/halt
rm -f /usr/local/sbin/reboot
rm -rf /etc/mysql

service mysqld start
service httpd start
amportal start
gui-fix

sed -i 's|$ttspick = 1|$ttspick = 0|' /var/www/html/reminders/index.php


# trim the number of Apache processes
echo " " >> /etc/httpd/conf/httpd.conf
echo "<IfModule prefork.c>" >> /etc/httpd/conf/httpd.conf
echo "StartServers       3" >> /etc/httpd/conf/httpd.conf
echo "MinSpareServers    3" >> /etc/httpd/conf/httpd.conf
echo "MaxSpareServers   4" >> /etc/httpd/conf/httpd.conf
echo "ServerLimit      5" >> /etc/httpd/conf/httpd.conf
echo "MaxClients       256" >> /etc/httpd/conf/httpd.conf
echo "MaxRequestsPerChild  4000" >> /etc/httpd/conf/httpd.conf
echo "</IfModule>" >> /etc/httpd/conf/httpd.conf
echo " " >> /etc/httpd/conf/httpd.conf

# fix phpMyAdmin for CentOS 7
sed -i 's|localhost|127.0.0.1|' /var/www/html/maint/phpMyAdmin/config.inc.php
service mysqld start
service httpd start
amportal start
amportal a r
asterisk -rx "database deltree dundi"
mkdir /etc/pbx
touch /etc/pbx/.incredible


echo "Randomizing all of your extension 701 and DISA passwords..."
lowest=111337
highest=982766
ext701=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
disapw=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
vm701=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
adminpw=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
mysql -uroot -ppassw0rd asterisk <<EOF
use asterisk;
update sip set data="$ext701" where id="701" and keyword="secret";
update disa set pin="$disapw" where disa_id=1;
update admin set value='true' where variable="need_reload";
EOF
sed -i 's|1234|'$vm701'|' /etc/asterisk/voicemail.conf
sed -i 's|701 =|;701 =|' /etc/asterisk/voicemail.conf
sed -i 's|1234 =|;1234 =|' /etc/asterisk/voicemail.conf
echo "701 => $vm701,701,yourname98199x@gmail.com,,attach=yes|saycid=yes|envelope=yes|delete=no" > /tmp/email.txt
sed -i '/\[default\]/r /tmp/email.txt' /etc/asterisk/voicemail.conf
rm -f /tmp/email.txt

/var/lib/asterisk/bin/module_admin reload
rm -f /var/www/html/piaf-index.tar.gz

# something in here changes the security model back to none
# or maybe it's already set that way and this just restarts it to load it
#/var/lib/asterisk/bin/module_admin upgrade framework
#/var/lib/asterisk/bin/module_admin upgrade core
#/var/lib/asterisk/bin/module_admin upgradeall
#/var/lib/asterisk/bin/module_admin upgradeall
#/var/lib/asterisk/bin/module_admin upgradeall
#/var/lib/asterisk/bin/module_admin upgrade cidlookup
#/var/lib/asterisk/bin/module_admin upgrade digium_phones
#/var/lib/asterisk/bin/module_admin upgrade digiumaddoninstaller
#/var/lib/asterisk/bin/retrieve_conf
#amportal a r
#amportal a an

# anyway we fix it again here before the reload
#mysql -u root -ppassw0rd -e "update asterisk.freepbx_settings set value = 'database' where keyword = 'AUTHTYPE' limit 1;"
#sed -i 's|AUTHTYPE=none|AUTHTYPE=database|' /etc/amportal.conf
#mysql -u root -ppassw0rd -e "update asterisk.admin set value='true' where variable='need_reload';"
#/var/lib/asterisk/bin/module_admin reload

# now we set the randomized admin password
#mysql -u root -ppassw0rd -e "update asterisk.ampusers set password_sha1 = '`echo -n $adminpw | sha1sum`' where username = 'admin' limit 1;"


echo " "

# Configuring IPtables
# Rules are saved in /etc/iptables
# /etc/init.d/iptables-persistent restart 
#apt-get install iptables-persistent -y
# add TM3 rules here
sed -i 's|INPUT ACCEPT|INPUT DROP|' /etc/sysconfig/ip6tables
# Here's the culprit...
# changing the next rule to DROP will kill the GUI on some hosted platforms like Digital Ocean
# but you get constant noise in the log where they're doing some heartbeat stuff
sed -i '/OUTPUT ACCEPT/a -A INPUT -s ::1 -j ACCEPT' /etc/sysconfig/ip6tables
# server IP address is?
if [[ "$release" = "7" ]]; then
 serverip=`ifconfig | grep "inet" | head -1 | cut -f 2 -d ":" | tail -1 | cut -f 10 -d " "`
else
 serverip=`ifconfig | grep "inet" | head -1 | cut -f 2 -d ":" | tail -1 | cut -f 1 -d " "`
fi
# user IP address while logged into SSH is?
userip=`echo $SSH_CONNECTION | cut -f 1 -d " "`
# public IP address in case we're on private LAN
publicip=`curl -s -S --user-agent "Mozilla/4.0" http://myip.incrediblepbx.com | awk 'NR==2'`
# WhiteList all of them by replacing 8.8.4.4 and 8.8.8.8 and 74.86.213.25 entries
cp /etc/sysconfig/iptables /etc/sysconfig/iptables.orig
cd /etc/sysconfig
# yep we use the same iptables rules on the Ubuntu platform
wget http://incrediblepbx.com/iptables4-ubuntu14.tar.gz
tar zxvf iptables4-ubuntu14.tar.gz
rm -f iptables4-ubuntu14.tar.gz
cp rules.v4.ubuntu14 iptables
sed -i 's|8.8.4.4|'$serverip'|' /etc/sysconfig/iptables
sed -i 's|8.8.8.8|'$userip'|' /etc/sysconfig/iptables
sed -i 's|74.86.213.25|'$publicip'|' /etc/sysconfig/iptables
badline=`grep -n "\-s  \-p" /etc/sysconfig/iptables | cut -f1 -d: | tail -1`
while [[ "$badline" != "" ]]; do
sed -i "${badline}d" /etc/sysconfig/iptables
badline=`grep -n "\-s  \-p" /etc/sysconfig/iptables | cut -f1 -d: | tail -1`
done
sed -i 's|-A INPUT -s  -j|#-A INPUT -s  -j|g' /etc/sysconfig/iptables
#Installing Fail2Ban
yum -y --skip-broken install fail2ban
# chronyd causes problems
if [[ "$release" = "7" ]]; then
 chkconfig chronyd off
 service chronyd stop
 systemctl disable firewalld.service
 systemctl stop firewalld.service
else
 cd /usr/local/sbin
 wget http://incrediblepbx.com/iptables-restart-6.tar.gz
 tar zxvf iptables-restart-6.tar.gz
 rm -f iptables-restart-6.tar.gz
fi
service iptables restart
service ip6tables restart
chkconfig iptables on
chkconfig ip6tables on
chkconfig httpd on
service httpd restart
if [[ "$release" = "7" ]]; then
 systemctl enable ntpd.service
 systemctl start ntpd.service
else
 chkconfig ntpd on
 service ntpd start
fi
sed -i '/Starting/a mkdir /var/run/fail2ban' /etc/rc.d/rc3.d/S92fail2ban
sed -i '/Starting/a mkdir /var/run/fail2ban' /etc/init.d/fail2ban
cd /etc/fail2ban
wget http://incrediblepbx.com/jail-R.tar.gz
tar zxvf jail-R.tar.gz
rm -f jail-R.tar.gz
service fail2ban start
chkconfig fail2ban on
service sendmail start
chkconfig sendmail on
if [[ "$release" = "7" ]]; then
 systemctl enable sshd.service
else
 chkconfig sshd on
fi

# Installing SendMail
#echo "Installing SendMail..."
#apt-get install sendmail -y

# Installing WebMin from official repo!
cd /root
echo "Installing WebMin..."
wget http://www.webmin.com/jcameron-key.asc
rpm --import jcameron-key.asc
rm jcameron-key.asc
cp webmin.repo /etc/yum.repos.d
yum -y --skip-broken install webmin
#yum -y install perl perl-Net-SSLeay openssl perl-IO-Tty
#TEST=`rpm -qa webmin`
#if [[ ! "$TEST" ]]; then
# wget http://prdownloads.sourceforge.net/webadmin/webmin-1.791-1.noarch.rpm
# rpm -Uvh webmin*
#fi
sed -i 's|10000|9001|g' /etc/webmin/miniserv.conf
service webmin restart
chkconfig webmin on

echo "Getting Webmin module for Asterisk server..."
cd /root
wget http://downloads.asterisk.org/pub/telephony/asterisk/webmin/webmin.tgz


echo "Installing command line gvoice for SMS messaging..."
cd /root
#mkdir pygooglevoice
yum -y install python-setuptools
easy_install -U setuptools
#yum -y install python-simplejson
#easy_install simplejson
#cd pygooglevoice
#wget http://nerdvittles.dreamhosters.com/pbxinaflash/source/pygooglevoice/pygooglevoice.tar.gz
#wget http://incrediblepbx.com/pygooglevoice.tar.gz
#tar zxvf pygooglevoice.tar.gz
#python setup.py install
#rm -f pygooglevoice.tar.gz
#cp /root/pygooglevoice/bin/gvoice /usr/bin/.
#yum -y install mercurial
#hg clone https://code.google.com/r/kkleidal-pygooglevoiceupdate/
#cd kk*
git clone https://github.com/pettazz/pygooglevoice
cd pygooglevoice
python setup.py install
cp -p bin/gvoice /usr/bin/.
cd /root
rm -rf pygooglevoice

echo "asterisk ALL = NOPASSWD: /sbin/shutdown" >> /etc/sudoers
echo "asterisk ALL = NOPASSWD: /sbin/reboot" >> /etc/sudoers
echo "asterisk ALL = NOPASSWD: /usr/bin/gvoice" >> /etc/sudoers
#cd /root
#wget http://incrediblepbx.com/morestuff.tar.gz
#tar zxvf morestuff.tar.gz
#rm -f morestuff.tar.gz
#rm -fr neorouter
echo " "

echo "Installing NeoRouter client..."
cd /root
TEST=`rpm -qa nrclient`
if [[ ! "$TEST" ]]; then
if $arch64; then
 wget http://download.neorouter.com/Downloads/NRFree/Update_2.3.1.4360/Linux/CentOS/nrclient-2.3.1.4360-free-centos-x86_64.rpm
else
 wget http://download.neorouter.com/Downloads/NRFree/Update_2.3.1.4360/Linux/CentOS/nrclient-2.3.1.4360-free-centos-i386.rpm
fi
yum -y install nrclient*
fi

# this needs some more work
# adjusting DNS entries for PPTP access to Google DNS servers
# sed -i 's|#ms-dns 10.0.0.1|ms-dns 8.8.8.8|' /etc/ppp/pptpd-options
#sed -i 's|#ms-dns 10.0.0.2|ms-dns 8.8.4.4|' /etc/ppp/pptpd-options
# Administrator still must do the following to bring PPTP on line
# 1. edit /etc/pptpd.conf and add localip and remoteip address ranges
# 2. edit /etc/ppp/chap-secrets and add credentials for PPTP access:
#  mybox pptpd 1234 * (would give everyone access to mybox using 1234 pw)
# 3. restart PPTPD: service pptpd restart


# tidy up stuff for CentOS 6.7
if [[ "$release" = "6" ]]; then
 cd /usr/local/sbin
 wget http://incrediblepbx.com/status67.tar.gz
 tar zxvf status67.tar.gz
 rm -f status67.tar.gz
fi

# Adding timezone-setup module for CentOS
cd /root
wget http://incrediblepbx.com/timezone-setup.tar.gz
tar zxvf timezone-setup.tar.gz
rm -f timezone-setup.tar.gz

# Adding confbridge app (this bug has been fixed )
# cp /usr/lib64/asterisk/modules/app_confbridge.so /usr/lib/asterisk/modules/.
# amportal restart

# Patching Wolfram Alpha installer for Ubuntu
#sed -i '/wget http:\/\/nerd.bz\/A7umMK/a mv A7umMK 4747.tgz' /root/wolfram/wolframalpha-oneclick.sh

# Patching grub so Ubuntu will shutdown and reboot by issuing command twice
# which sure beats NEVER which was the previous situation. Thanks, @jeff.h
#sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT=""|GRUB_CMDLINE_LINUX_DEFAULT="quiet splash acpi=force"|' /etc/default/grub
#update-grub

# patching PHP and AGI apps that didn't have <?php prefix
#for f in /var/lib/asterisk/agi-bin/*.php; do echo "Updating $f..." && sed -i ':a;N;$!ba;s/<?\n/<?php\n/' $f; done
#for f in /var/lib/asterisk/agi-bin/*.agi; do echo "Updating $f..." && sed -i ':a;N;$!ba;s/<?\n/<?php\n/' $f; done

# set up directories for Telephone Reminders
#mkdir /var/spool/asterisk/reminders
#mkdir /var/spool/asterisk/recurring
#chown asterisk:asterisk /var/spool/asterisk/reminders
#chown asterisk:asterisk /var/spool/asterisk/recurring

# fix /etc/hosts so SendMail works with Asterisk
sed -i 's|localhost |pbx.local localhost IncrediblePBX.local |' /etc/hosts

# install Incredible Backup and Restore
#cd /root
#wget http://incrediblepbx.com/incrediblebackup11.tar.gz
#tar zxvf incrediblebackup11.tar.gz
#rm -f incrediblebackup11.tar.gz

# adding Port Knock daemon: knockd
cd /root
yum -y install libpcap* curl gawk
TEST=`rpm -qa knock-server`
if [[ ! "$TEST" ]]; then
if $arch64; then
# wget http://nerdvittles.dreamhosters.com/pbxinaflash/source/knock/knock-server-0.5-7.el6.nux.x86_64.rpm
 wget http://incrediblepbx.com/knock-server-0.5-7.el6.nux.x86_64.rpm
else
# wget http://nerdvittles.dreamhosters.com/pbxinaflash/source/knock/knock-server-0.5-7.el6.nux.i686.rpm
 wget http://incrediblepbx.com/knock-server-0.5-7.el6.nux.i686.rpm
fi
rpm -ivh knock-server*
rm -f knock-server*.rpm
fi
echo "[options]" > /etc/knockd.conf
echo "       logfile = /var/log/knockd.log" >> /etc/knockd.conf
echo "" >> /etc/knockd.conf
echo "[opencloseALL]" >> /etc/knockd.conf
echo "        sequence      = 7:udp,8:udp,9:udp" >> /etc/knockd.conf
echo "        seq_timeout   = 15" >> /etc/knockd.conf
echo "        tcpflags      = syn" >> /etc/knockd.conf
echo "        start_command = /sbin/iptables -A INPUT -s %IP% -j ACCEPT" >> /etc/knockd.conf
echo "        cmd_timeout   = 3600" >> /etc/knockd.conf
echo "        stop_command  = /sbin/iptables -D INPUT -s %IP% -j ACCEPT" >> /etc/knockd.conf
chmod 640 /etc/knockd.conf
# randomize ports here
lowest=6001
highest=9950
knock1=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
knock2=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
knock3=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
sed -i 's|7:udp|'$knock1':tcp|' /etc/knockd.conf
sed -i 's|8:udp|'$knock2':tcp|' /etc/knockd.conf
sed -i 's|9:udp|'$knock3':tcp|' /etc/knockd.conf
if [[ "$release" = "7" ]]; then
 EPORT=`ifconfig | head -1 | cut -f 1 -d ":"`
 echo "OPTIONS=\"-i $EPORT\"" > /etc/sysconfig/knockd
else
 chkconfig --level 2345 knockd on
 service knockd start
fi
if $arch64; then
 yum -y install ftp://rpmfind.net/linux/dag/redhat/el6/en/x86_64/dag/RPMS/miniupnpc-1.5-1.el6.rf.x86_64.rpm
else
 yum -y install ftp://rpmfind.net/linux/dag/redhat/el6/en/i386/dag/RPMS/miniupnpc-1.5-1.el6.rf.i686.rpm
fi
upnpc -r 5060 udp $knock1 tcp $knock2 tcp $knock3 tcp


#/var/lib/asterisk/bin/module_admin reload
#rm -f /var/www/html/index_custom.php
#cp /var/www/html/index.php /var/www/html/index_custom.php

#patch status
#mv /root/status /usr/local/sbin/status
#chattr +i /usr/local/sbin/status

# web root
#cd /var/www/html
#mv index_custom.php index_custom2.php


# clear out proprietary logos and final cleanup
cd /root
/root/logos-b-gone
rm -f anaconda*
rm -f epel*
rm -f install.*
rm -f nrclient*
rm -f rpmforge*
rm -f yumlist.*

#sendmailmp3 support
#cd /usr/sbin
#wget http://pbxinaflash.com/sendmailmp3.tar.gz
#wget http://incrediblepbx.com/sendmailmp3.tar.gz
#tar zxvf sendmailmp3.tar.gz
#rm sendmailmp3.tar.gz
#chmod 0755 sendmailmp3
yum -y install lame
yum -y install flac
yum -y install dos2unix
yum -y install unix2dos
ln -s /usr/sbin/sendmailmp3 /usr/bin/sendmailmp3
cd /root

# and some bug fixes
chmod 664 /var/log/asterisk/full
sed -i 's|libmyodbc.so|libmyodbc5.so|' /root/odbc-gen.sh
sed -i 's|mysql restart|mysqld restart|' /root/odbc-gen.sh
sed -i 's|/var/run/mysqld/mysqld.sock|/var/lib/mysql/mysql.sock|' /root/odbc-gen.sh
/root/odbc-gen.sh
echo "[cel]" >> /etc/asterisk/cel_odbc_custom.conf
echo "connection=MySQL-asteriskcdrdb" >> /etc/asterisk/cel_odbc_custom.conf
echo "loguniqueid=yes" >> /etc/asterisk/cel_odbc_custom.conf
echo "table=cel" >> /etc/asterisk/cel_odbc_custom.conf
#sed -i "s|''|'localhost'|" /etc/freepbx.conf
#sed -i "s|'localhost'; //for sqlite3|''; //for sqlite3|" /etc/freepbx.conf
#cd /var/www/html
#rm -f favicon.ico
#wget http://incrediblepbx.com/favicon.ico
#chown asterisk:asterisk favicon.ico
#cp -p favicon.ico /var/www/manual/images/.
#cp -p favicon.ico /var/www/html/reminders/.
#cp -p favicon.ico /var/www/html/admin/modules/framework/amp_conf/htdocs/admin/images/.
#cp -p favicon.ico /var/www/html/admin/images/.
#cp -p favicon.ico /usr/src/freepbx/amp_conf/htdocs/admin/images/.
#mysql -u root -ppassw0rd mysql -e "SET PASSWORD FOR 'asteriskuser'@'localhost' = PASSWORD('amp109');"
#amportal restart
#echo "/usr/local/sbin/iptables-restart"	>> /etc/rc.local
#echo "exit 0" >> /etc/rc.local
#sed -i 's|AllowOverride None|AllowOverride All|' /etc/httpd/conf/httpd.conf
#service httpd restart
/var/lib/asterisk/bin/freepbx_setting SIGNATURECHECK 0
amportal a r
#sed -i 's|1024:65535|9999:65535|' /etc/sysconfig/iptables
#sed -i 's|1024:65535|9999:65535|' /etc/sysconfig/rules.v4.ubuntu14
#iptables-restart

# version 11-12.1 additions
#cd /usr/local/sbin
#wget http://incrediblepbx.com/gui-fix.tar.gz
#tar zxvf gui-fix.tar.gz
#rm -f gui-fix.tar.gz

cd /var/lib/asterisk/agi-bin
mv speech-recog.agi speech-recog.last.agi
wget --no-check-certificate https://raw.githubusercontent.com/zaf/asterisk-speech-recog/master/speech-recog.agi
chown asterisk:asterisk speech*
chmod 775 speech*

# Add Kennonsoft menus
#cd /var/www/html
#wget http://incrediblepbx.com/kennonsoft.tar.gz
#tar zxvf kennonsoft.tar.gz
#rm -f kennonsoft.tar.gz

# Add HTTP security
#cd /etc/pbx
#wget http://incrediblepbx.com/http-security.tar.gz
#tar zxvf http-security.tar.gz
#rm -f http-security.tar.gz
echo "Include /etc/pbx/httpdconf/*" >> /etc/httpd/conf/httpd.conf
service httpd restart


#GV patch
#sed -i 's| noload = res_jabber.so|;noload = res_jabber.so|' /etc/asterisk/modules.conf
#sed -i 's| noload = chan_gtalk.so|;noload = chan_gtalk.so|' /etc/asterisk/modules.conf

# unload res_hep unless your system support IPv6
echo "noload = res_hep.so" >> /etc/asterisk/modules.conf

# remove the Ubuntu fax installer
rm -f /root/incrediblefax11_ubuntu14.sh

if [[ "$release" = "7" ]]; then
 mv /usr/local/sbin/status /usr/local/sbin/status6
 cp -p /root/status7 /usr/local/sbin/status
 systemctl stop firewalld
 systemctl mask firewalld
 yum -y install iptables-services
 systemctl enable iptables
 systemctl restart iptables
 iptables-restart
 rpm -e postfix
 yum -y install sendmail
 service sendmail restart
fi

# set up the root login scripts
echo 'export PS1="WARNING: Always run Incredible PBX behind a secure hardware-based firewall.  \n\[$(tput setaf 2)\]\u@\h:\w $ \[$(tput sgr0)\]"' >> /root/.bash_profile
echo '/root/update-IncrediblePBX' >> /root/.bash_profile
echo 'status -p' >> /root/.bash_profile

# change overwrite defaults
sed -i 's|rm -i|rm -f|' /root/.bashrc
sed -i 's|cp -i|cp -f|' /root/.bashrc
sed -i 's|mv -i|mv -f|' /root/.bashrc

# change Asterisk to run as asterisk user
amportal kill
chown -R asterisk:asterisk /var/run/asterisk
sed -i '/END INIT INFO/a AST_USER="asterisk"\nAST_GROUP="asterisk"' /etc/init.d/asterisk
sed -i 's|;runuser|runuser|' /etc/asterisk/asterisk.conf
sed -i 's|;rungroup|rungroup|' /etc/asterisk/asterisk.conf
amportal kill
amportal start

# patch GoogleTTS
cd /tmp
git clone https://github.com/zaf/asterisk-googletts.git
cd asterisk-googletts
chown asterisk:asterisk goo*
sed -i 's|speed = 1|speed = 1.3|' googletts.agi
cp -p goo* /var/lib/asterisk/agi-bin/.
cd cli
chown asterisk:asterisk goo*
cp -p goo* /var/lib/asterisk/agi-bin/.

# post the current version
echo $version > /etc/pbx/.version

systemctl restart sshd.service
/usr/local/sbin/iptables-restart
echo "/var/lib/asterisk/bin/freepbx_setting SIGNATURECHECK 0" >> /usr/local/sbin/gui-fix
echo "amportal a r" >> /usr/local/sbin/gui-fix
/usr/local/sbin/gui-fix

# rc.local reconfiguration
rm -f /etc/rc.local
sed -i '/local/d' /etc/rc.d/rc.local
sed -i '/exit/d' /etc/rc.d/rc.local
sed -i '/sleep/d' /etc/rc.d/rc.local
chmod a+x /etc/rc.d/rc.local
ln -s /etc/rc.d/rc.local /etc/rc.local
echo "touch /var/lock/subsys/local" >> /etc/rc.local
echo "sleep 5" >> /etc/rc.local
echo "/usr/local/sbin/gui-fix" >> /etc/rc.local
echo "sleep 5" >> /etc/rc.local
echo "/usr/local/sbin/iptables-restart" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local
touch /etc/pbx/.update718

# patch AsteriDex SpeedDialer
cd /root
wget http://incrediblepbx.com/update-speeddial.tar.gz
tar zxvf update-speeddial.tar.gz
rm -f update-speeddial.tar.gz
./update-speeddial

# add Asterisk 13 upgrade script
cd /root
wget http://incrediblepbx.com/upgrade-asterisk-to-current.tar.gz
tar zxvf upgrade-asterisk-to-current.tar.gz
rm -f upgrade-asterisk-to-current.tar.gz*

# Asterisk 13 patch to make local calling work... no idea why
cd /usr/src/asterisk-13*
make
make install
amportal kill
amportal start

# ucp patch
cd /var/www/html
mv recordings recordings2
ln -s ucp recordings
cd /root

# last minute GPL module updates
/var/lib/asterisk/bin/module_admin upgradeall
amportal a r

# remove module signature checking
cd /root
wget http://incrediblepbx.com/GPG-patch.tar.gz
tar zxvf GPG-patch.tar.gz
rm -f GPG-patch.tar.gz*
./GPG-patch

# patch for Incredible PBX Lean VMware OVF installs
SSHTEST=`/usr/bin/md5sum /etc/ssh/ssh_host_rsa_key.pub`
if [ "$SSHTEST" = "76ad2ab8173cf14ea5c502be09ecce74  /etc/ssh/ssh_host_rsa_key.pub" ]; then
 rm -f /etc/ssh/ssh_host*
# rpm -e openssh-server openssh-xinetd
# yum -y install openssh-server openssh-xinetd
# service sshd restart
fi

# patch for Incredible PBX Full VMware OVF installs
SSHTEST=`/usr/bin/md5sum /etc/ssh/ssh_host_rsa_key.pub`
if [ "$SSHTEST" = "c7276d5da63ad664710c5c6ea95b395f  /etc/ssh/ssh_host_rsa_key.pub" ]; then
 rm -f /etc/ssh/ssh_host*
# rpm -e openssh-server openssh-xinetd
# yum -y install openssh-server openssh-xinetd
# service sshd restart
fi

# switching to SVOX PicoTTS from GoogleTTS for 32-bit only
if [ "`uname -m`" = "x86_64" ]; then
 echo " "
else
 cd /
 wget http://incrediblepbx.com/picotts.tar.gz
 tar zxvf picotts.tar.gz
 rm -f picotts.tar.gz*
 cd /root
 ./picotts-install.sh
 sed -i 's|en)|en-US)|' /etc/asterisk/extensions_custom.conf
 sed -i 's|googletts|picotts|' /etc/asterisk/extensions_custom.conf
fi

# adding gvoice and Google SMS patch
cd /
wget http://incrediblepbx.com/gvoice-patch.tar.gz
tar zxvf gvoice-patch.tar.gz

chown asterisk:asterisk /etc/modprobe.d/dahdi*

# clear out postfix
rpm -e postfix

# add-ip fix
ln -s /etc/rc.d/init.d/iptables /etc/rc.d/init.d/iptables-persistent

# bugfix for Reminders HTML interface
rm -f /etc/pbx/httpdconf/reminders.conf.1

# patch to remove option for incoming callers to place outbound calls
mysql -uroot -ppassw0rd asterisk -e "update freepbx_settings set value = 'tr' where keyword = 'DIAL_OPTIONS' limit 1"
mysql -uroot -ppassw0rd asterisk -e "update freepbx_settings set value = '' where keyword = 'TRUNK_OPTIONS' limit 1"
amportal a r

# updates to support Google Voice OAUTH
cd /var/www/html/admin
sed -i 's|Google Voice Password|Google Voice Refresh Token|' modules/motif/views/edit.php
sed -i 's|This is your Google Voice Password|This is your Google Voice refresh token|' modules/motif/views/edit.php
echo 13-12.3 > /etc/pbx/.version

clear
echo "Knock ports for access to $publicip set to TCP: $knock1 $knock2 $knock3" > /root/knock.FAQ
echo "UPnP activation attempted for UDP 5060 and your knock ports above." >> /root/knock.FAQ
echo "To enable knockd on your server, issue the following commands:" >> /root/knock.FAQ
echo "  chkconfig --level 2345 knockd on" >> /root/knock.FAQ
echo "  service knockd start" >> /root/knock.FAQ
echo "To enable remote access, issue these commands from any remote server:" >> /root/knock.FAQ
echo "nmap -p $knock1 $publicip && nmap -p $knock2 $publicip && nmap -p $knock3 $publicip" >> /root/knock.FAQ
echo "Or install iOS PortKnock or Android DroidKnocker on remote device." >> /root/knock.FAQ
echo " "

echo "*** Reset your Incredible PBX GUI admin password. Run /root/admin-pw-change NOW!"
echo "*** Configure your correct time zone by running: /root/timezone-setup"
echo "*** For fax support, run: /root/incrediblefax11.sh"
echo " "
echo "WARNING: Server access locked down to server IP address and current IP address."
echo "*** Modify /etc/sysconfig/iptables and restart IPtables BEFORE logging out!"
echo "To restart IPtables, issue command: iptables-restart"
echo " "
echo "Knock ports for access to $publicip set to TCP: $knock1 $knock2 $knock3"
echo "UPnP activation attempted for UDP 5060 and your knock ports above."
echo "To enable knockd server for remote access, read /root/knock.FAQ"
echo " "
echo "You may access webmin as root at https://$serverip:9001"
echo " "
read -p "Press Enter key to reboot now. Enjoy!"
reboot
