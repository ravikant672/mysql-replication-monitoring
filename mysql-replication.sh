#!/bin/bash
## Author: Ravikant Kumar

if [ ! -f $statusFile ];then
	#if replicationStatus txt not created then create it
	echo $'Up\nUp\nnodelay\n0\n0\nTime |Status| Delay;' >  $statusFile
fi
#Grab the lines for each and use Gawk to get the last part of the string(Yes/No)
Slave_SQL_Running=`mysql -h $host -u $userName --password=$Password -e "show slave status \G" |grep -i "Slave_SQL_Running:"|gawk '{print $2}'`
Slave_IO_Running=`mysql -h $host -u $userName --password=$Password -e "show slave status \G" |grep -i "Slave_IO_Running"|gawk '{print $2}'`

#slow_slave_status=`mysql -h $host -u $userName --password=$Password -e "show slave status\G"`
#echo -e "$slow_slave_status"

show_slave_status=`mysql -h $host -u $userName --password=$Password -e "show slave status \G"`
#Last_Errno=`mysql -h $host -u $userName --password=$Password -e "show slave status \G" |grep -i "Last_Errno:"|gawk -F":" '{print $2}'`
#Last_Error=`mysql -h $host -u $userName --password=$Password -e "show slave status \G" |grep -i "Last_Error:"|gawk -F":" '{print $2}'`
#Last_IO_Errno=`mysql -h $host -u $userName --password=$Password -e "show slave status \G" |grep -i "Last_IO_Errno:"|gawk -F":" '{print $2}'`
#Last_IO_Error=`mysql -h $host -u $userName --password=$Password -e "show slave status \G" |grep -i "Last_IO_Error:"|gawk -F":" '{print $2}'`
#Last_SQL_Errno=`mysql -h $host -u $userName --password=$Password -e "show slave status \G" |grep -i "Last_SQL_Errno:"|gawk -F":" '{print $2}'`
#Last_SQL_Error=`mysql -h $host -u $userName --password=$Password -e "show slave status \G" |grep -i "Last_SQL_Error:"|gawk -F":" '{print $2}'`

SECONDS_BEHIND_MASTER=`mysql -h $host -u $userName --password=$Password -e "SHOW SLAVE STATUS\G"| grep "Seconds_Behind_Master" |gawk '{print $2}'`

#Slave_SQL_Running="No"
#Slave_IO_Running="No"

echo $Slave_SQL_Running
echo $Slave_IO_Running
echo $SECONDS_BEHIND_MASTER

if [[ "$Slave_SQL_Running" = "No" || "$Slave_IO_Running" = "No" ]]; then
        currentStat="Down"
        ## Fetching Current State from file
        privCurrStat=`sed '1q;d' $statusFile`
        ## Setting Current state on line no 1.
        sed -i "1s/.*/Down/" $statusFile
        ## Setting Last state on line no 2
        sed -i "2s/.*/$privCurrStat/" $statusFile
else
        currentStat="Up"
        ## Fetching Current State from file
        privCurrStat=`sed '1q;d' $statusFile`
        ## Setting Current state on line no 1.
        sed -i "1s/.*/Up/" $statusFile
        ## Setting Last state on line no 2
        sed -i "2s/.*/$privCurrStat/" $statusFile
fi

Time=`date +%H:%M`
Delay=$SECONDS_BEHIND_MASTER
#Delay="11"

#=========================================================================
## Send SMS Alert at every 10 min when last delay is greater than 120 sec.
send_sms() {
url="http://websms5.swigcom.com/PushSMS.php?username=USERNAME&password=PASSWORD&smstext=$1"
## Replace ; into line terminating url decode %0A and also space into + sign for webSMS
finalURL=`echo $url | sed 's/;/%0A/g' | sed 's/ /+/g'`
curl "$finalURL&CustomerNumber=$mobileNo"
}

##=====================================================================
## Send Email Alert
send_email() {
	echo "==========sending email========="
	#echo -e "$2" | mail -s "$(echo -e "$1\nContent-Type: text/html")" $email
	#echo -e "Content-Type: text/html\nTo: $email\nSubject: $1\nMIME-Version: 1.0 $2" | sendmail -t
	(echo "From: DB Alert <dbalert@lenskart.in>"; echo "To: $email"; echo "Subject: $1"; echo "Content-Type: text/html"; echo "MIME-Version: 1.0"; echo ""; echo -e "$2";) | /usr/sbin/sendmail -t
	#echo -e "$2" | mail -s "$1" $email
}

send_slack_alert () {
	echo "=======slack alert sending======"
	curl -s -d "payload={\"username\": \"scriptuser\",\"channel\": \"#$slack_channel\",\"text\": \"*$1*\n$2\"}" $slack_webhook_url
}

##=========================================================================

show_slave_status_for_email=$(echo "${show_slave_status//$'\n'/<br/>}")

msgBody="<div style=''>Hi Team,<br><br>Replication on the slave MySQL server($serverName/$host) has been stopped. <br>Current status : <b style='color:red;font-size:24px'>$currentStat</b><br>Date: $(date)<br><br><div style='background-color: #eff2f7;'>$show_slave_status_for_email</div></div><br><br>Regards<br>Team DBA"

#msgBody="<div style=''>Hi Team,<br><br>Replication on the slave MySQL server($serverName/$host) has been stopped. <br>Current status : <b style='color:red;font-size:24px'>$currentStat</b><br>Date: $(date)<br><br><table bgcolor='#f4f6f9' style='font-family: Menlo;text-align:left;' ><tbody><tr><th style='border-bottom: 2px solid black;'>MySQL Slave Status<th><th style='width:60%'></th></tr><tr><td>Slave_SQL_Running: </td><td>$Slave_SQL_Running</td></tr><tr><td>Slave_IO_Running: </td><td>$Slave_IO_Running</td></tr><tr><td>Last_Errno: </td><td>$Last_Errno</td></tr><tr><td>Last_Error: </td><td>$Last_Error</td></tr><tr><td>Last_IO_Errno: </td><td>$Last_IO_Errno</td></tr><tr><td>Last_IO_Error: </td><td>$Last_IO_Error</td></tr><tr><td>Last_SQL_Errno: </td><td>$Last_SQL_Errno</td></tr><tr><td>Last_SQL_Error: </td><td>$Last_SQL_Erro</td></tr></tbody></table></div><br><br>Regards<br>Team DBA"

#msgBody="Hi Team\nAlert: Replication Status:- $currentStat at $(date)\nSecond Behid Master:\t$Delay\n\nSlave_SQL_Running:\t$Slave_SQL_Running\nSlave_IO_Running:\t$Slave_IO_Running\nLast_Errno:\t$Last_Errno\nLast_Error:\t$Last_Error\nLast_IO_Errno:\t$Last_IO_Errno\nLast_IO_Error:\t$Last_IO_Error\nLast_SQL_Errno:\t$Last_SQL_Errno\nLast_SQL_Error:\t$Last_SQL_Error\n"

#msgBody="Hi Team\nAlert: Replication Status:- $currentStat at $(date)\nSecond Behid Master:\t$Delay\n\n\t######### slow_slave_status #######\n$slow_slave_status"

if [[ "$currentStat" = "Down" && "$privCurrStat" = "Up" ]]; then
        #send_sms "Replication is Down on  Server(@$Time)."
	echo $currentStat 
	echo $privCurrStat
        send_email "Replication status down on $serverName($host)." "$msgBody"
        send_slack_alert "Replication status down on $serverName($host) Server." ""
elif [[ "$currentStat" = "Up" && "$privCurrStat" = "Down" ]]; then
        #send_sms "Replication is Up on serverName Server(@$Time)."
        send_email "Replication status up on $serverName($host)." "Hi Team<br>Alert: <b>Replication is </b><b style='color:green;font-size:20px'>$currentStat</b> at $(date)<br>Second Behid Master:<b style='color:red;font-size:20px'>$Delay Seconds.</b><br><br>Regards<br>Team DBA"
        send_slack_alert "Replication status up on $serverName($host)." "Hi Team\nAlert: Replication is $currentStat at $(date)\nSecond Behid Master:\t$Delay"
fi
##========================================================================
##========================================================================
sendSmsStat=`sed '3q;d' $statusFile`
if [[ "$Delay" = "0" && "$sendSmsStat" = "delay" ]]; then
        #send_sms "Currently ($Time) there is no Replication delay on $serverName"
        send_email "Replication Delay Status @ $serverName($host)" "Hi Team,<br>Now the slave($host)($serverName) is in sync with its master server.<br>Date: $(date)<br><p>Delay: <b style='color:green;font-size:24px'>$Delay</b></p><br><br>Regards<br>Team DBA"
        send_slack_alert "Replication Delay Status @ $serverName($host)" "Hi Team,\nNow the slave($host)($serverName) is in sync with its master server.\nDate: $(date)\nDelay: $Delay"
        sed -i "3s/.*/nodelay/" $statusFile
        sed -i "4s/.*/0/" $statusFile # This is used for 10minAlert
        sed -i "5s/.*/0/" $statusFile # This is used for 30minAlert
fi

### Seting 10minAlert and 30minAlert status to 0 because of at commnad value is remain setted when delay=0 
if [[ "$Delay" = "0" ]]; then
	sed -i "4s/.*/0/" $statusFile # This is used for 10minAlert
        sed -i "5s/.*/0/" $statusFile # This is used for 30minAlert
fi

## ========================================================================
## This section is used for sinding delay alert on interval basis

t10minAlert=`sed '4q;d' $statusFile`
t30minAlert=`sed '5q;d' $statusFile`
if [[ "$Delay" -ge "$delay_threshold" && "$t10minAlert" = "0" && "$t30minAlert" = "0" ]];then
	## Sending alert msg
       	replication_blocking_thread=`mysql -h $host -u $userName --password=$Password < $replication_blocking_thread`
	### Changing \n with <br> for email formating
	replication_blocking_thread=$(echo "${replication_blocking_thread//$'\n'/<br/>}")
        sql_querys=`mysql -h $host -u $userName --password=$Password < $sql_querys`
	### Changing \n with <br> for email formating
	sql_querys=$(echo "${sql_querys//$'\n'/<br/>}")
	echo "sending first email"
	#send_email "test" " first mail test fjkasgjkflksajdi"
        send_email "Replication Delay Status @ $serverName($host)" "Hi Team,<br>There is replication problem. <br>Second Behid Master:<b style='color:red;font-size:20px'>$Delay Seconds.</b><br><br><b style='border-bottom: 2px solid black;'>Replication Blocking Thread</b><br><div style='background-color:#eff2f7;text-align:left'>`echo -e "$replication_blocking_thread"`</div><br><br><b style='border-bottom: 2px solid black;'>Top 10 SQL Query</b><br><div style='background-color:#eff2f7;text-align:left'>`echo -e "$sql_querys"`</div><br><br>Regards<br>Team DBA"
	send_slack_alert "Replication Delay Status @ $serverName($host)" "Hi Team,\nThere is replication problem.\nSecond Behid Master: $Delay Seconds."
	sed -i "4s/.*/1/" $statusFile # Set 1 for mail send on first detection
	# Set 10 after 10 min of first alert for next mail afte 10 min..
	echo "sed -i '4s/.*/10/' $statusFile" | at now + 10 min
	sed -i "3s/.*/delay/" $statusFile

elif [[ "$Delay" -ge "$delay_threshold" && "$t10minAlert" = "10" && "$t30minAlert" = "0" ]];then
	## Sending Alert after 10 min of previous alert.
       	replication_blocking_thread=`mysql -h $host -u $userName --password=$Password < $replication_blocking_thread`
	### Changing \n with <br> for email formating
        replication_blocking_thread=$(echo "${replication_blocking_thread//$'\n'/<br/>}")
        sql_querys=`mysql -h $host -u $userName --password=$Password < $sql_querys`
	### Changing \n with <br> for email formating
        sql_querys=$(echo "${sql_querys//$'\n'/<br/>}")
	echo "sending email on 10 min condition"
        send_email "Replication Delay Status @ $serverName($host)" "Hi Team,<br>There is replication problem since 10 min. <br>Second Behid Master:<b style='color:red;font-size:20px'>$Delay Seconds.</b><br><br><b style='border-bottom: 2px solid black;'>Replication Blocking Thread</b><br><div style='background-color:#eff2f7;text-align:left'>`echo -e "$replication_blocking_thread"`</div><br><b style='border-bottom: 2px solid black;'>Top 10 SQL Query</b><br><div style='background-color:#eff2f7;text-align:left'>`echo -e "$sql_querys"`</div><br><br>Regards<br>Team DBA"
	send_slack_alert "Replication Delay Status @ $serverName($host)" "Hi Team,\nThere is replication problem since 10 min.\nSecond Behid Master: $Delay Seconds."
	sed -i "5s/.*/1/" $statusFile # Set 1 for mail send on 10 min of detection."
	 # Set 10 after 30 min of first alert for next mail afte 30 min.
	echo "sed -i '5s/.*/30/' $statusFile" | at now + 30 min
elif [[ "$Delay" -ge "$delay_threshold" && "$t10minAlert" = "10" && "$t30minAlert" = "30" ]];then
	## Sending Alert after 30 min of previous alert.	
       	replication_blocking_thread=`mysql -h $host -u $userName --password=$Password < $replication_blocking_thread`
	### Changing \n with <br> for email formating
        replication_blocking_thread=$(echo "${replication_blocking_thread//$'\n'/<br/>}")
        sql_querys=`mysql -h $host -u $userName --password=$Password < $sql_querys`
	### Changing \n with <br> for email formating
        sql_querys=$(echo "${sql_querys//$'\n'/<br/>}")
	echo "sending 30 min alert"
        send_email "Replication Delay Status @ $serverName($host)" "Hi Team,<br>There is replication problem since 40 min. <br>Second Behid Master:<b style='color:red;font-size:20px'>$Delay Seconds.</b><br><br><b style='border-bottom: 2px solid black;'>Replication Blocking Thread</b><br><div style='background-color:#eff2f7;text-align:left'>`echo -e "$replication_blocking_thread"`</div><br><b style='border-bottom: 2px solid black;'>Top 10 SQL Query</b><br><div style='background-color:#eff2f7;text-align:left'>`echo -e "$sql_querys"`</div><br><br>Regards<br>Team DBA"
	send_slack_alert "Replication Delay Status @ $serverName($host)" "Hi Team,\nThere is replication problem since 40 min.\nSecond Behid Master: $Delay Seconds."
	sed -i "5s/.*/1/" $statusFile # Set 1  for dont repet alert after40 min.
fi


##=========================================================================
## This section for mobile sms | every min delay status- 10 min 

echo "$Time | $currentStat | $Delay;" >> $statusFile
lines=`wc -l < $statusFile`
if [ "$lines" = "16" ];then
        msg_text=`sed -n '6,16p' $statusFile | sed 's/;/<br>/g'`
	#echo $msg_text
        if [ "$Delay" -ge $delay_threshold ]; then
                # echo "sending sms"
        	#replication_blocking_thread=`mysql -h $host -u $userName --password=$Password < $replication_blocking_thread`
		### Changing \n with <br> for email formating
	        #replication_blocking_thread=$(echo "${replication_blocking_thread//$'\n'/<br/>}")
	        #sql_querys=`mysql -h $host -u $userName --password=$Password < $sql_querys`
		### Changing \n with <br> for email formating
	        #sql_querys=$(echo "${sql_querys//$'\n'/<br/>}")
                #send_sms "Replication @ $serverName;$sms_text"
		echo "sending delay alert email"
                #send_email "Replication Delay Status @ $serverName($host)" "<h3>Hi Team,<br>There is replication problem. <br>Second Behid Master:<b style='color:red;font-size:20px'>$Delay Seconds.</b></h3><br><b>Previos State of Replication Delay</b><br><div style='background-color:#eff2f7'>$msg_text</div><br><b style='border-bottom: 5px solid green;'>Replication Blocking Thread</b><div style='background-color:#eff2f7;text-align:left'>$replication_blocking_thread</div><br><b style='border-bottom: 5px solid green;'>Top 10 SQL Query</b><div style='background-color:#eff2f7;text-align:left'>$replication_blocking_thread</div><br><br>Regards<br>Team DBA"
                #send_slack_alert "Replication Delay Status @ $serverName($host)" "$msg_text"
                sed -i "3s/.*/delay/" $statusFile
        fi
        ## Deleting line form file
        sed -i '7,16d' $statusFile
fi
