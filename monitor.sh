#!/bin/bash
## Author : Ravikant
DIR="$(cd "$(dirname "$0")" && pwd)"
replication_blocking_thread=$DIR/replication_blocking_thread.sql
sql_querys=$DIR/sql_querys.sql

## Get all host list from config file
hostsArray=`grep "host=" $DIR/.config.sh | cut -d '"' -f 2`
#echo "$hostsArray"

#Set the field separator to new line
IFS=$'\n'
# Loop on all host from .config file
for host in $hostsArray
do
	echo $host
	source $DIR/.config.sh $host
	statusFile="$DIR/$trackfile"
	logfile="$DIR/logfile.txt"
	##=====================
	source $DIR/mysql-replication.sh
	##=======================
#echo $email
#echo $host
#echo $serverName
#echo $userName
#echo $Password
#echo $statusFile

done



