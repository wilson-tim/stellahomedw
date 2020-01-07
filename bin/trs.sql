--This is trs.sql
spool trs.lis
set newpage 0
set verify off
set heading off
set feedback off
set termout on
set pagesize 0
set echo off
set linesize 220

select season_year,season_type,count(*)
from transport_sale 
where season_year=to_char(to_date(substr('&1',2,2),'rr'),'yyyy')
and season_type=upper(substr('&1',1,1))
and details_updated_date=trunc(sysdate)
group by season_year,season_type;
