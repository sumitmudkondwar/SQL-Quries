--**************************************************************************************************************************************************
SELECT convert(varchar, getdate(), 100) -- mon dd yyyy hh:mmAM
SELECT convert(varchar, getdate(), 101) -- mm/dd/yyyy – 10/02/2008                  
SELECT convert(varchar, getdate(), 102) -- yyyy.mm.dd – 2008.10.02           
SELECT convert(varchar, getdate(), 103) -- dd/mm/yyyy
SELECT convert(varchar, getdate(), 104) -- dd.mm.yyyy
SELECT convert(varchar, getdate(), 105) -- dd-mm-yyyy
SELECT convert(varchar, getdate(), 106) -- dd mon yyyy
SELECT convert(varchar, getdate(), 107) -- mon dd, yyyy
SELECT convert(varchar, getdate(), 108) -- hh:mm:ss
SELECT convert(varchar, getdate(), 109) -- mon dd yyyy hh:mm:ss:mmmAM (or PM)
SELECT convert(varchar, getdate(), 110) -- mm-dd-yyyy
SELECT convert(varchar, getdate(), 111) -- yyyy/mm/dd
SELECT convert(varchar, getdate(), 112) -- yyyymmdd
SELECT convert(varchar, getdate(), 113) -- dd mon yyyy hh:mm:ss:mmm
SELECT convert(varchar, getdate(), 114) -- hh:mm:ss:mmm(24h)
SELECT convert(varchar, getdate(), 120) -- yyyy-mm-dd hh:mm:ss(24h)
SELECT convert(varchar, getdate(), 121) -- yyyy-mm-dd hh:mm:ss.mmm
SELECT convert(varchar, getdate(), 126) -- yyyy-mm-ddThh:mm:ss.mmm
select CONVERT(VARCHAR(8), GETDATE(), 1) -- MM/DD/YY
--change column name in sql server
EXEC sp_RENAME 'table_name.old_name', 'new_name', 'COLUMN'

--**************************************************************************************************************************************************
--Loop for last 7 days except mentioned days
--**************************************************************************************************************************************************
DECLARE @count INT, @sql varchar(max)

SET @count = 1
set @sql = ''


WHILE (@count <= 7)
BEGIN
    
	if (datename(dw, DATEADD(day,-@count,getdate())) not in ('Sunday','Saturday') )
	begin
		
		set @sql = @sql + ', [Price NAV LC '  + convert(varchar,getdate()-@count,3) + '] varchar(20), [Price Bid LC ' + convert(varchar,getdate()-@count,3) + '] varchar(20), [Price Offer LC ' + convert(varchar,getdate()-@count,3) + '] varchar(20)'

	end
    
	SET @count = @count + 1

END

exec('CREATE TABLE testsumit([Lipper Id] int' + @sql + ')')


select * from testsumit
--*************************************************************************************************************
-- to select 37 chars from left
select left(replace(CAST(ATTRIBUTE_FUND.MANAGERNAME AS VARCHAR(100)),',',' '), 37) + '...' AS COL12
--*************************************************************************************************************
BEGIN TRY
    BEGIN TRANSACTION
        DELETE FROM test
        RAISERROR (15600,-1,-1, 'mysp_CreateCustomer');  
        COMMIT
END TRY
BEGIN CATCH
	print 'rollback'
    ROLLBACK
END CATCH
--*************************************************************************************************************



--*************************************************************************************************************
-- DATE Diffrence except weekends for last 10 days only
--*************************************************************************************************************
select top 100 * from Csupp_perfDyRoll_LC_IND
where 
[Lipper ID]=11000564 and 
perf_date between (DATEADD(dd, DATEDIFF(dd, 0, cast('1/25/2019' as date)) - 14, 0)) and (cast(DATEADD(dd, DATEDIFF(dd, 0, cast('1/25/2019' as date)) 
- (case when Datename(weekday,cast('1/25/2019' as date)) = 'Monday' then 3 else 1 end), 0) as date))
--*************************************************************************************************************



--*************************************************************************************************************
-- IMPORTANT IMFORMATION SEARCH QURIES
--*************************************************************************************************************

select * from TestDB..config where grp ='TWChinaTrust_1700'

select * from TestDB..config where args like '%TWChinaTrust%' and enabled=1 order by seq

select * from asd.sys.objects where type = 'U' and name = 'Uni_FP_TW_Deauth_p_fundlist'

select * from ifeed.INFORMATION_SCHEMA.COLUMNS

select * from ifeed.INFORMATION_SCHEMA.VIEWS

sp_tables Uni_FP_TW_Deauth_p_fundlist


SELECT OBJECT_NAME(OBJECT_ID) AS DatabaseName, last_user_update,*
FROM sys.dm_db_index_usage_stats
WHERE database_id = DB_ID( 'testdb')
AND OBJECT_ID=OBJECT_ID('config')
select * from sys.objects where name = 'config'


--*************************************************************************************************************



--Country is Taiwan
--Fund is not Umbrella
--Status is Acitve

SELECT p.spid
,convert(char(12), d.name) db_name
, program_name
, convert(char(12), l.name) login_name
, convert(char(12), hostname) hostname
, cmd
, p.status
, p.blocked
, login_time
, last_batch
, p.spid
FROM      master..sysprocesses p
JOIN      master..sysdatabases d ON p.dbid =  d.dbid
JOIN      master..syslogins l ON p.sid = l.sid
WHERE     p.blocked = 0
AND       EXISTS (  SELECT 1
          FROM      master..sysprocesses p2
          WHERE     p2.blocked = p.spid )

--**************************************************************************************************


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

--**********************************************************************************************************
