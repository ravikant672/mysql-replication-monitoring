SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST where time>2 and command<>"Sleep" and user not in ("system user","repluser","event_scheduler","mysqld_exporter") order by time DESC LIMIT 5\G;
