#/bin/bash
#sudo scp evn@172.16.12.13:~/dataMDMS-linux-x86-64_1.tar.gz ../
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "${red}This script must be run as root${reset}" 1>&2
   exit 1
fi
# ...
cd /home/evn
echo "${green}----------------------------------${reset}"
pwd
echo "${green}----------------------------------${reset}"
echo "${green}Stop tomcat...${reset}"

service tomcat stop
STATUS=$?
if [ $STATUS -ne 0 ]; then
echo "${red}Stop tomcat Failed${red}"
exit;
fi

cp -R web/ICT/* /opt/ict/tomcat7/webapps/ICT/
STATUS=$?
if [ $STATUS -ne 0 ]; then
echo "${red}Copy tomcat Failed${reset}"
fi

service tomcat start
STATUS=$?
if [ $STATUS -ne 0 ]; then
echo "${red}Start tomcat Failed${reset}"
else
echo "${green}Start tomcat OK${reset}"
fi

