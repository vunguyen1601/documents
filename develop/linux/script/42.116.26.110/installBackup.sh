#!/bin/bash
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
USER_MYSQL=$1
PASS_MYSQL=$2
DIR_BK=$3
HOUR_BK=$4
MINUTE_BK=$5
if [ "$#" -eq  "0" ]
   then
     echo "Khong co tham so truyen vao"
     echo "root pass /home/dir 2 21"     
     exit
else
    echo $0 $1 $2 $3 $4 $5 $USER 
fi

echo $0 $1 $2 $3 $4 $5 $USER
if id -u "ict" >/dev/null 2>&1; then
        echo "user exists"
else
        adduser ict
        echo "ishtpc!@#qaz123" | passwd --stdin ict
        echo 'ict ALL=(ALL:ALL) ALL' >> /etc/sudoers
fi
echo "${green}Cai dat xtrabackup${reset}"
echo "[percona]" > /etc/yum.repos.d/Percona.repo
echo "name = CentOS \$releasever - Percona" >> /etc/yum.repos.d/Percona.repo
echo "baseurl = http://repo.percona.com/centos/\$releasever/os/\$basearch/" >> /etc/yum.repos.d/Percona.repo
echo "enabled = 1" >> /etc/yum.repos.d/Percona.repo
echo "gpgkey = http://www.percona.com/downloads/RPM-GPG-KEY-percona" >> /etc/yum.repos.d/Percona.repo
echo "pgcheck = 1" >> /etc/yum.repos.d/Percona.repo

yum update -y
yum install -y xtrabackup
echo "${green}Tao user xbict cho MySQL${reset}"
mysql -u$USER_MYSQL -p$PASS_MYSQL -e "DROP USER 'xbict'@'localhost';"
mysql -u$USER_MYSQL -p$PASS_MYSQL -e "CREATE USER 'xbict'@'localhost' IDENTIFIED BY 'xb753123';"
mysql -u$USER_MYSQL -p$PASS_MYSQL -e "GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT, CREATE TABLESPACE, PROCESS, SUPER, CREATE, INSERT, SELECT ON *.* TO 'xbict'@'localhost';"
mysql -u$USER_MYSQL -p$PASS_MYSQL -e "FLUSH PRIVILEGES;"

echo "${green}Cau hinh xtrabackup${reset}"
gpasswd -a ict mysql

mkdir -p $DIR_BK/dbbackup/full/
mkdir -p $DIR_BK/dbbackup/inc/
chown -R ict:ict $DIR_BK/dbbackup



TIMEBEGIN="$(date +%s)"
echo "${green}Chay full backup lan dau tien $TIMEBEGIN ${reset}"
innobackupex --use-memory=4G --user=xbict --no-lock --password=xb753123 $DIR_BK/dbbackup/full/
TIMEEND="$(date +%s)"
DUTIME="$(expr $TIMEEND-$TIMEBEGIN)";
echo "${green}End full backup lan dau tien $DUTIME ${reset}"
EBC="$(ls -t $DIR_BK/dbbackup/full/ | head -1)"
echo $EBC

TIMEBEGIN="$(date +%s)"
echo "${green}Tao ban backup incremental dau tien $TIMEBEGIN ${reset}"
innobackupex --use-memory=4G --user=xbict --no-lock --password=xb753123 --incremental --incremental-basedir=$DIR_BK/dbbackup/full/$EBC/ $DIR_BK/dbbackup/inc/
IMEEND="$(date +%s)"
DUTIME="$(expr $TIMEEND-$TIMEBEGIN)";
echo "${green}End incremental backup lan dau tien $DUTIME ${reset}"
mkdir -p /opt/ict/shell

echo "#/bin/bash" > /opt/ict/shell/backupDB.sh

echo "EBC=\"\$(ls -t $DIR_BK/dbbackup/inc/ | head -1)\"" >> /opt/ict/shell/backupDB.sh

echo "innobackupex --use-memory=4G --user=xbict --no-lock --password=xb753123 --incremental --incremental-basedir=$DIR_BK/dbbackup/inc/\$EBC/ $DIR_BK/dbbackup/inc/" >> /opt/ict/shell/backupDB.sh

chmod +x /opt/ict/shell/backupDB.sh

echo "${green}add crontab${reset}"
#crontab -r ict
#crontab -u ict -e
echo "$MINUTE_BK $HOUR_BK * * * /opt/ict/shell/backupDB.sh" 
#echo '21 2 * * * /opt/ict/shell/backupDB.sh' | crontab -
#(crontab -l ict; echo "$MINUTE_BK $HOUR_BK * * * /opt/ict/shell/backupDB.sh > /dev/null 2>&1";) | sort | uniq | crontab -
(crontab -u ict -l; echo "$MINUTE_BK $HOUR_BK * * * /opt/ict/shell/backupDB.sh") | grep -v "no crontab" | sort | uniq | crontab -u ict -
# append_cronjob('21 2 * * * /opt/ict/shell/backupDB.sh');; 


echo "${green}finish<<<${reset}" 

