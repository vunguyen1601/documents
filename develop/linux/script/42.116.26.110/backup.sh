#!/bin/bash
NOW=$(date +"%d_%m_%Y")
cd /home/ict/backups
#echo aa > $NOW.txt
mysqldump -uict -p!iIcCtT@ ictfw_db --routines | gzip > ictfw_db_$NOW.sql.gz
find . -mtime +6 -exec rm {} \;
