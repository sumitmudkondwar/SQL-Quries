/* Pulls Current Running Queries in DB Server*/
SELECT s.session_id
    ,r.STATUS
    ,r.blocking_session_id AS 'blocked_by'
    ,r.wait_type
    ,r.wait_resource
    ,CONVERT(VARCHAR, DATEADD(ms, r.wait_time, 0), 8) AS 'wait_time'
    ,r.cpu_time
    ,r.logical_reads
    ,r.reads
    ,r.writes
    ,CONVERT(VARCHAR, DATEADD(ms, r.total_elapsed_time, 0), 8) AS 'elapsed_time'
    ,CAST((
            '<?query --  ' + CHAR(13) + CHAR(13) + Substring(st.TEXT, (r.statement_start_offset / 2) + 1, (
                    (
                        CASE r.statement_end_offset
                            WHEN - 1
                                THEN Datalength(st.TEXT)
                            ELSE r.statement_end_offset
                            END - r.statement_start_offset
                        ) / 2
                    ) + 1) + CHAR(13) + CHAR(13) + '--?>'
            ) AS XML) AS 'query_text'
      ,DB_NAME(database_id) [Database]
      ,SUBSTRING(st.text,(r.statement_start_offset/2)+1,
            CASE WHEN statement_end_offset=-1 OR statement_end_offset=0 
            THEN (DATALENGTH(st.Text)-r.statement_start_offset/2)+1 
            ELSE (r.statement_end_offset-r.statement_start_offset)/2+1
            END) [Executing SQL]
    ,COALESCE(QUOTENAME(DB_NAME(st.dbid)) + N'.' + QUOTENAME(OBJECT_SCHEMA_NAME(st.objectid, st.dbid)) + N'.' + QUOTENAME(OBJECT_NAME(st.objectid, st.dbid)), '') AS 'stored_proc'
    --,qp.query_plan AS 'xml_plan'  -- uncomment (1) if you want to see plan
    ,r.command
    ,s.login_name
    ,s.host_name
    ,s.program_name
    ,s.host_process_id
    ,s.last_request_end_time
    ,s.login_time
    ,r.open_transaction_count
      ,last_wait_type
FROM sys.dm_exec_sessions AS s
INNER JOIN sys.dm_exec_requests AS r ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
--OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) AS qp -- uncomment (2) if you want to see plan
WHERE r.wait_type NOT LIKE 'SP_SERVER_DIAGNOSTICS%'
    OR r.session_id != @@SPID
ORDER BY r.cpu_time DESC
    ,r.STATUS
    ,r.blocking_session_id
    ,s.session_id
