--This is keys.sql
spool keys.lis
set newpage 0
set verify off
set heading on
set feedback off
set termout on
set pagesize 100
set linesize 220
col today new_value xtoday noprint format a1 trunc
select to_char(sysdate,'DY: DD-MON-YYYY') today from dual;
col owner format a8 trunc
col table_name format a25 trunc
col constraint_name format a25 trunc
col column_name format a28 trunc
col child_tables format a25 trunc
ttitle left '[Page Number:' format 999999 sql.pno ']  <<'xtoday'>> -
[Filename: Keys.sql]' skip 1-
'<<< This gives info on the key columns. >>>' skip 2
break on owner on table_name skip 1 on constraint_name

select b.owner,b.table_name,b.constraint_name,b.column_name,a.table_name child_tables
from all_cons_columns b full outer join all_constraints a on a.table_name=b.table_name using (table_name,constraint_name,owner) 
where b.table_name=upper('&1') 
and b.constraint_name not like 'SYS%'
order by b.owner,b.table_name,b.constraint_name;

