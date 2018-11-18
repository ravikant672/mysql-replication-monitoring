SELECT 
    r.trx_id waiting_trx_id,
    r.trx_mysql_thread_id waiting_thread,
    TIMESTAMPDIFF(SECOND,
        r.trx_wait_started,
        CURRENT_TIMESTAMP) wait_time,
    r.trx_query waiting_query,
    l.lock_table waiting_table_lock,
    b.trx_id blocking_trx_id,
    b.trx_mysql_thread_id blocking_thread,
    SUBSTRING(p.HOST,
        1,
        INSTR(p.HOST, ':') - 1) blocking_host,
    SUBSTRING(p.HOST,
        INSTR(p.HOST, ':') + 1) blocking_port,
    IF(p.COMMAND = 'Sleep', p.TIME, 0) idel_in_trx,
    b.trx_query blocking_query
FROM
    information_schema.INNODB_LOCK_WAITS w
        INNER JOIN
    information_schema.INNODB_TRX b ON b.trx_id = w.blocking_trx_id
        INNER JOIN
    information_schema.INNODB_TRX r ON r.trx_id = w.requesting_trx_id
        INNER JOIN
    information_schema.INNODB_LOCKS l ON w.requested_lock_id = l.lock_id
        LEFT JOIN
    information_schema.PROCESSLIST p ON p.ID = b.trx_mysql_thread_id
ORDER BY wait_time DESC\G;
