SELECT * FROM INFORMATION_SCHEMA.PROCESSLIST where time>1 and command<>"Sleep" and DB is not null and user  in ("system user") order by time DESC\G;
