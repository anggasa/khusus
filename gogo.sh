#!/bin/bash
#
# Script Copyright Worm
# ==========================
# 

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
#MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0'`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";
#ether=`ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:`
#if [ "$ether" = "" ]; then
#        ether=eth0
#fi

#MYIP=$(ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1)
#if [ "$MYIP" = "" ]; then
#		MYIP=$(wget -qO- ipv4.icanhazip.com)
#fi
#MYIP2="s/xxxxxxxxx/$MYIP/g";

# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update;apt-get -y install wget curl;

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# set repo
wget -O /etc/apt/sources.list "https://raw.githubusercontent.com/anggasa/worm/master/sources.list.debian7"
wget "http://www.dotdeb.org/dotdeb.gpg"
wget "http://www.webmin.com/jcameron-key.asc"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
cat jcameron-key.asc | apt-key add -;rm jcameron-key.asc

# remove unused
apt-get -y --purge remove samba*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

# update
apt-get -y update; apt-get -y upgrade;

# install essential package
echo "mrtg mrtg/conf_mods boolean true" | debconf-set-selections
#apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs openvpn vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install build-essential

# disable exim
service exim4 stop
sysv-rc-conf exim4 off

# update apt-file
apt-file update


# install screenfetch
cd
wget 'https://raw.githubusercontent.com/anggasa/worm/master/screenfetch-dev'
mv screenfetch-dev /usr/bin/screenfetch-dev
chmod +x /usr/bin/screenfetch-dev
echo "clear" >> .profile
echo "screenfetch-dev" >> .profile

# webserver + ssh2
apt-get -y install apache2 php5
apt-get -y install libssh2-php

# setting dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart
service dropbear restart

cd

# install fail2ban
apt-get -y install fail2ban;service fail2ban restart

# install webmin
cd
wget -O webmin-current.deb "http://www.webmin.com/download/deb/webmin-current.deb"
dpkg -i --force-all webmin-current.deb;
apt-get -y -f install;
rm /root/webmin-current.deb
service webmin restart

# download script
cd
wget -O speedtest_cli.py "https://raw.githubusercontent.com/anggasa/worm/master/speedtest_cli.py"
wget -O bench-network.sh "https://raw.githubusercontent.com/anggasa/worm/master/bench-network.sh"
wget -O ps_mem.py "https://raw.githubusercontent.com/anggasa/worm/master/ps_mem.py"
wget -O dropmon "https://raw.githubusercontent.com/anggasa/worm/master/dropmon.sh"
wget -O user-login.sh "https://raw.githubusercontent.com/anggasa/worm/master/user-login.sh"
wget -O user-expired.sh "https://raw.githubusercontent.com/anggasa/worm/master/user-expired.sh"
#wget -O userlimit.sh "https://raw.githubusercontent.com/anggasa/worm/master/limit.sh"
wget -O user-list.sh "https://raw.githubusercontent.com/anggasa/worm/master/user-list.sh"
wget -O /etc/issue.net "https://raw.githubusercontent.com/anggasa/worm/master/banner"
echo "0 0 * * * root /root/user-expired.sh" > /etc/cron.d/user-expired
#echo "@reboot root /root/userlimit.sh" > /etc/cron.d/userlimit
echo "0 0 * * * root /usr/bin/reboot" > /etc/cron.d/reboot
echo "* * * * * service dropbear restart" > /etc/cron.d/dropbear
#sed -i '$ i\screen -AmdS check /root/autokill.sh' /etc/rc.local
chmod +x bench-network.sh
chmod +x speedtest_cli.py
chmod +x ps_mem.py
#chmod +x user-login.sh
chmod +x user-login.sh
#chmod +x user-expired.sh
chmod +x user-expired.sh
#chmod +x userlimit.sh
chmod +x dropmon
chmod +x user-list.sh
cp /root/create-user.sh /usr/bin/usernew
chmod +x /usr/bin/usernew
cd /usr/bin
curl https://raw.githubusercontent.com/anggasa/worm/master/trial.sh > trial
chmod +x trial
cd
# finishing
chown -R www-data:www-data /home/vps/public_html
service cron restart
service php-fpm start
service ssh restart
service dropbear restart
service fail2ban restart

service webmin restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# info
clear
echo "MAKASIH BROH ~Angga Saputra~" | tee -a log-install.txt
cd
rm -f /root/debian7.sh
