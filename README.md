# Mysql replication monitoring script
This script is used for monitoring and alerting of MySQL replication.

**File descriptin and usages.**
1. **.config.sh** : This file is used for configuration of each DB HOST. 
2. **monitor.sh** : This file is main executable script which include .config.sh and mysql-replication.sh file.
  *We add this script in crontab for monitoring DB Replication*
  ```bash
  */1 * * * * sh /root/mysql-replication-monitoring/monitor.sh > /tmp/test.txt
  ````
 3. **mysql-replicatin.sh** : This script contain all logic for replication monitoring and alerting. 
 4. There is 3 sql file which contain sql queries.
 
 *This script send email alert and sms alert for Replication Down or Delay.*
 *This script store some value in .txt file for current and previous status. And also we store some value which is used for alerting on specific time interval. To manage timeinterval we are using at command *
 ```bash
 at now + 10 min
 ```
 
*For alerting we are using sendmail command. And on server we configure sendmail command with google mail SMTP*
```bash
## Send Email Alert
send_email() {
	echo "==========sending email========="
	(echo "From: DB Alert <dbalert@lenskart.in>"; echo "To: $email"; echo "Cc: ajeets@valyoo.in"; echo "Subject: $1 at $(date +"%Y-%m-%d %I:%M %p")"; echo "Content-Type: text/html"; echo "MIME-Version: 1.0"; echo ""; echo -e "$2";) | /usr/sbin/sendmail -t
}
```



  
  
