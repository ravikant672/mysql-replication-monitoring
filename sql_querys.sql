SELECT 
      it.trx_id AS trx_id,
      it.trx_state AS trx_state,
      it.trx_started AS trx_started,
      it.trx_mysql_thread_id AS trx_mysql_thread_id,
      CURRENT_TIMESTAMP - it.trx_started AS RUN_TIME,
      pl.user AS USER,
      pl.host AS HOST,
      pl.db AS db,
      pl.time AS trx_run_time,
      pl.INFO as INFO
    FROM
      information_schema.INNODB_TRX it,
      information_schema.processlist pl
    WHERE
      pl.id=it.trx_mysql_thread_id
    ORDER BY RUN_TIME DESC LIMIT 10\G;
