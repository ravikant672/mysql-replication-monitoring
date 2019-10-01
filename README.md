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
 
  
  
