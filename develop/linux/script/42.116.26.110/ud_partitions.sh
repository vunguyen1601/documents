#!/bin/bash
SERVER="42.116.26.110"
NOW=$(date +"%Y%m%d%H%M%S")
MONTH_NEXT=$(date -d "1 month" +"%m")
MONTH_NEXT_NEXT=$(date -d "2 month" +"%m")
MONTH_YEAR_NEXT=$(date -d "1 month" +"%Y")
FILE_SQL=$MONTH_NEXT$MONTH_YEAR_NEXT".sql"
#SMS CONFIG
URL_SMS="http://onesms.mobifone.vn:8082/SMSAPI/SendSMS?"
MSISDN="01228030801"
SMS_TEMPLATE_CODE="2126"
ACCSMS="0901800879"
PASSSMS="abc@123"

echo "" > $FILE_SQL
array=( evn_rawdata evn_loadprofiledata evn_alarmdata )
for TABLE in "${array[@]}"
do
	#delete partitions end 
	echo "ALTER TABLE $TABLE DROP PARTITION "$TABLE"_pEnd;" >> $FILE_SQL
	#add month next
	echo "ALTER TABLE $TABLE ADD PARTITION (
    		PARTITION "$TABLE"_p$MONTH_NEXT$MONTH_YEAR_NEXT VALUES LESS THAN (to_seconds('$MONTH_YEAR_NEXT-$MONTH_NEXT_NEXT-01 00:00:00')),
    		PARTITION "$TABLE"_pEnd VALUES LESS THAN MAXVALUE
		);" >> $FILE_SQL

done
echo "SELECT count(*) from evn_devicea;" > $FILE_SQL
result=$(mysql --user=ict --password=!iIcCtT@ --database=ictfw_db < ${FILE_SQL} 2>&1 )
RESULT=$?
#echo $RESULT
MESSAGE_SMS="SV:$SERVER%20DA%20OK%20PARTITIONS%20$NOW"
if [ $RESULT != 0 ]
then
	MESSAGE_SMS="SV:$SERVER%20LOI%20TAO%20PARTITIONS%20$NOW"
fi

#SEND SMS 
#echo $MESSAGE_SMS
#[ $? = 0 ] || 
#echo $result
#LOGIN SMS
URL_CN="${URL_SMS}msg_name=login&account=${ACCSMS}&password=${PASSSMS}"
result=$(curl -X GET $URL_CN 2>/dev/null )
#echo $result
array=(`echo $result | sed 's/&/\n/g'`)
#echo $result
#echo ${array[1]} # -> bar 
array=(`echo ${array[1]} | sed 's/=/\n/g'`)
SESSIONID=${array[1]}
#echo $SESSIONID
#SEND SMS
URL_CN="${URL_SMS}msg_name=send_sms&session_id=${SESSIONID}&sms_id=1&msisdn=${MSISDN}&sms_template_code=${SMS_TEMPLATE_CODE}&param1=${MESSAGE_SMS}&param2=NA"
#echo "URL: $URL_CN"
result=$(curl -X GET $URL_CN 2>/dev/null )
#echo $result
#LOGOUT SMS
URL_CN="${URL_SMS}msg_name=logout&session_id=${SESSIONID}"
result=$(curl -X GET $URL_CN 2>/dev/null )
